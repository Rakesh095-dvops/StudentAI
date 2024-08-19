import os
import csv
import shutil
from docx2pdf import convert

def convert_docx_to_pdf(docx_path, pdf_path):
    """
    Convert a DOCX file to PDF.
    :param docx_path: Path to the DOCX file.
    :param pdf_path: Path to save the PDF file.
    """
    try:
        convert(docx_path, pdf_path)
    except Exception as e:
        print(f"An error occurred during conversion: {e}")

def process_folders(folder_path, csv_file, output_folder):
    # Create the output folder if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Load the CSV file
    with open(csv_file, mode='r', newline='') as infile:
        reader = list(csv.DictReader(infile))

    # Add cv_file column if it doesn't exist
    if 'cv_file' not in reader[0]:
        fieldnames = reader[0].keys()
        fieldnames = list(fieldnames) + ['cv_file']
    else:
        fieldnames = reader[0].keys()

    updated_rows = []

    for row in reader:
        if 'cv_file' in row and row['cv_file'] == 'NA' or 'cv_file' not in row:
            first_name = row['Name'].split()[0]
            userid = row['userid']
            matched_folder = None
            matched_file = None

            # Find the folder that starts with the first name
            for folder_name in os.listdir(folder_path):
                if folder_name.startswith(first_name):
                    matched_folder = os.path.join(folder_path, folder_name)
                    break

            if matched_folder:
                # Check for files in the folder
                files = os.listdir(matched_folder)
                if len(files) == 1:
                    file_path = os.path.join(matched_folder, files[0])
                    file_extension = os.path.splitext(files[0])[1]

                    if file_extension.lower() == '.docx':
                        # Convert DOCX to PDF
                        pdf_filename = f"{row['Name']}_{userid}.pdf"
                        pdf_path = os.path.join(output_folder, pdf_filename)
                        convert_docx_to_pdf(file_path, pdf_path)
                        matched_file = pdf_filename
                    elif file_extension.lower() == '.pdf':
                        # Just copy the PDF file
                        pdf_filename = f"{first_name}_{userid}.pdf"
                        pdf_path = os.path.join(output_folder, pdf_filename)
                        shutil.copy(file_path, pdf_path)
                        matched_file = pdf_filename
                else:
                    matched_file = 'NA'

            row['cv_file'] = matched_file if matched_file else 'NA'
        updated_rows.append(row)

    # Write the updated CSV
    with open(csv_file, mode='w', newline='') as outfile:
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(updated_rows)

# Example usage
folder_path = "./cvs"
csv_file = "./updated_contacts.csv"
output_folder = "./final_cv"
process_folders(folder_path, csv_file, output_folder)
