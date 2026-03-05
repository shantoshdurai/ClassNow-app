import requests

PROJECT_ID = "studio-4155999944-16272"
API_KEY = "AIzaSyD1-EdouHHKdVb9PsgoX4vwM_HHvW3Won0"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def delete_document(path):
    url = f"{BASE_URL}/{path}?key={API_KEY}"
    resp = requests.delete(url)
    return resp

def list_documents(path):
    url = f"{BASE_URL}/{path}?key={API_KEY}"
    resp = requests.get(url)
    if resp.status_code == 200:
        data = resp.json()
        return data.get('documents', [])
    return []

print("🚀 Cleaning up '2nd-year' duplicate...")

# Path to the duplicate year
year_path = "departments/school-of-engineering-and-technology/years/2nd-year"

# 1. List and delete sections within 2nd-year
sections = list_documents(f"{year_path}/sections")
for section in sections:
    section_name = section['name'].split('/')[-1]
    
    # List and delete schedule entries for each section
    schedule_entries = list_documents(f"{year_path}/sections/{section_name}/schedule")
    for entry in schedule_entries:
        entry_id = entry['name'].split('/')[-1]
        delete_document(f"{year_path}/sections/{section_name}/schedule/{entry_id}")
    
    # Delete the section document itself
    delete_document(f"{year_path}/sections/{section_name}")
    print(f"  Deleted section: {section_name}")

# 2. Delete the year document
r = delete_document(year_path)
if r.status_code in (200, 204):
    print("\n✅ Successfully removed '2nd-year' document and its subcollections.")
    print("Now only '2024' will appear in your app.")
else:
    print(f"\n❌ Error deleting '2nd-year': {r.status_code}")
