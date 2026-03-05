import json
import requests

PROJECT_ID = "studio-4155999944-16272"
API_KEY = "AIzaSyD1-EdouHHKdVb9PsgoX4vwM_HHvW3Won0"

# Firestore REST API base
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

with open("tool/new_timetable.json", "r", encoding="utf-8") as f:
    classes = json.load(f)

print(f"Loaded {len(classes)} class entries")

def set_document(path, fields_dict):
    """Create or overwrite a Firestore document via REST API"""
    # Convert Python dict to Firestore format
    fs_fields = {}
    for k, v in fields_dict.items():
        if isinstance(v, str):
            fs_fields[k] = {"stringValue": v}
        elif isinstance(v, int):
            fs_fields[k] = {"integerValue": str(v)}
        elif isinstance(v, bool):
            fs_fields[k] = {"booleanValue": v}
    
    url = f"{BASE_URL}/{path}?key={API_KEY}"
    resp = requests.patch(url, json={"fields": fs_fields})
    return resp

def add_document(collection_path, fields_dict):
    """Add a new document to a Firestore collection"""
    fs_fields = {}
    for k, v in fields_dict.items():
        if isinstance(v, str):
            fs_fields[k] = {"stringValue": v}
        elif isinstance(v, int):
            fs_fields[k] = {"integerValue": str(v)}
    
    url = f"{BASE_URL}/{collection_path}?key={API_KEY}"
    resp = requests.post(url, json={"fields": fs_fields})
    return resp

# Step 1: Ensure dept doc exists
print("Setting up department doc...")
r = set_document(
    "departments/school-of-engineering-and-technology",
    {"name": "School of Engineering and Technology", "code": "SET"}
)
print(f"  Dept: {r.status_code}")

# Step 2: Ensure year doc exists
print("Setting up year doc...")
r = set_document(
    "departments/school-of-engineering-and-technology/years/2024",
    {"name": "2024"}
)
print(f"  Year: {r.status_code}")

# Step 3: Group by section
from collections import defaultdict
sections = defaultdict(list)
for c in classes:
    sections[c["section"]].append(c)

print(f"Found {len(sections)} sections: {list(sections.keys())}")

# Step 4: For each section, create section doc + add schedule entries
total_added = 0
for section_name, entries in sections.items():
    # Create section doc
    r = set_document(
        f"departments/school-of-engineering-and-technology/years/2024/sections/{section_name}",
        {"name": section_name}
    )
    if r.status_code not in (200, 201):
        print(f"  Section {section_name} FAILED: {r.status_code} {r.text[:200]}")
        continue
    
    # Add each class to schedule subcollection
    for entry in entries:
        r = add_document(
            f"departments/school-of-engineering-and-technology/years/2024/sections/{section_name}/schedule",
            {
                "subject": entry["subject"],
                "code": entry["code"],
                "mentor": entry["mentor"],
                "room": entry["room"],
                "day": entry["day"],
                "startTime": entry["startTime"],
                "endTime": entry["endTime"],
            }
        )
        if r.status_code not in (200, 201):
            print(f"    Entry FAILED: {r.status_code} {r.text[:100]}")
        else:
            total_added += 1
    
    print(f"  Section {section_name}: uploaded {len(entries)} classes")

print(f"\n✅ Done! Total uploaded: {total_added} classes across {len(sections)} sections")
