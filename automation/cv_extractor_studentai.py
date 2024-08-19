import os
import csv
import requests

def upload_file(file_path, uid):
    url = f"http://localhost:3002/api/basicresume/upload/{uid}"
    try:
        with open(file_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(url, files=files)
            if response.status_code == 201:
                return "completed"
            else:
                return "failed"
    except Exception as e:
        print(f"An error occurred: {e}")
        return "failed"

def process_csv(csv_file, cv_folder):
    # Load the CSV file
    with open(csv_file, mode='r', newline='') as infile:
        reader = list(csv.DictReader(infile))

    # Determine if extracted_update column exists
    if 'extracted_update' not in reader[0]:
        fieldnames = list(reader[0].keys()) + ['extracted_update']
    else:
        fieldnames = list(reader[0].keys())

    updated_rows = []

    for row in reader:
        if 'extracted_update' in row and row['extracted_update'] != 'pending':
            updated_rows.append(row)
            continue
        
        if row['cv_file'] == 'NA':
            row['extracted_update'] = 'pending'
        else:
            file_path = os.path.join(cv_folder, row['cv_file'])
            if os.path.exists(file_path):
                status = upload_file(file_path, row['userid'])
                row['extracted_update'] = status
            else:
                row['extracted_update'] = 'failed'

        updated_rows.append(row)

    # Write the updated CSV
    with open(csv_file, mode='w', newline='') as outfile:
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(updated_rows)

# Example usage
csv_file = "./updated_contacts.csv"
cv_folder = "./final_cv"
process_csv(csv_file, cv_folder)
