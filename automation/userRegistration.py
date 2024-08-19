import csv
import requests
import json

# Define the API endpoint
url = "http://studentaiapi.prashantdey.in/auth/organization/registerUserOrg"

# Define the organization ID
organization_id = "66aa1a915502e3cceb4403b5"

# Read the CSV file
csv_file = 'extracted_contacts.csv'

# Function to register a user
def register_user(name, email, phone):
    organization_id = "66aa1a915502e3cceb4403b5"
    url = "http://studentaiapi.prashantdey.in/auth/user/registerUserOrg"
    payload = {
        "name": name,
        "email": email,
        "phoneNo": phone,
        "organization": organization_id
    }
    response = requests.post(url, json=payload)
    
    # Print the status code and response text
    print(f"Status Code: {response.status_code}")
    print(f"Response Text: {response.text}")
    
    try:
        return response.json()
    except json.JSONDecodeError:
        return {"error": "Invalid JSON response"}

# Read the CSV and register each user
with open(csv_file, mode='r') as file:
    csv_reader = csv.DictReader(file)
    for row in csv_reader:
        name = row['Name']
        email = row['Email']
        phone = row['Phone']
        result = register_user(name, email, phone)
        print(f"User: {name}, Email: {email}, Phone: {phone}")
        print(f"Response: {result}")
        print("-" * 50)
