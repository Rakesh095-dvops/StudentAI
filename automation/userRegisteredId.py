import csv
import json

# Load user.json data
with open('alluser.json', 'r') as json_file:
    user_data = json.load(json_file)

# Create a dictionary mapping email to user_id
email_to_id = {user['email']: user['_id'] for user in user_data['users']}

# Read the CSV file and prepare to update it with user ids
csv_file = 'extracted_contacts.csv'
updated_rows = []

with open(csv_file, mode='r') as file:
    csv_reader = csv.DictReader(file)
    fieldnames = csv_reader.fieldnames + ['userid']  # Add new field 'userid'
    
    for row in csv_reader:
        email = row['Email']
        user_id = email_to_id.get(email, '')  # Fetch the user_id from the dictionary
        row['userid'] = user_id  # Add the user_id to the row
        updated_rows.append(row)

# Write the updated data back to the CSV file
with open('updated_contacts.csv', mode='w', newline='') as file:
    csv_writer = csv.DictWriter(file, fieldnames=fieldnames)
    csv_writer.writeheader()
    csv_writer.writerows(updated_rows)

print("CSV file updated with user IDs successfully.")
