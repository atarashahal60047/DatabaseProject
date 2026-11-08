import random
import re
import os

# Functions to extract IDs dynamically from your SQL files
def extract_patient_ids(filepath):
    ids = []
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            ids = re.findall(r"into\s+PATIENT\s*\(.*?\)\s*values\s*\(\s*(\d{9})", content, re.IGNORECASE)
    return list(set(ids))

def extract_doctor_ids(filepath):
    ids = []
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            ids = re.findall(r"into\s+DOCTOR\s*\(.*?\)\s*values\s*\(\s*(\d+)", content, re.IGNORECASE)
    return list(set(ids))

def extract_dispense_ids(filepath):
    ids = []
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Matches: INSERT INTO DISPENSING (DispenseID, ... VALUES (1, ...
            ids = re.findall(r"VALUES\s*\(\s*(\d+)", content, re.IGNORECASE)
    return [int(i) for i in set(ids)]

def extract_medication_codes(filepath):
    codes = []
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            codes = re.findall(r"VALUES\s*\(\s*(\d+)", content, re.IGNORECASE)
    return [int(c) for c in set(codes)]

# 1. Load real IDs from project files
patient_file_path = "../mockarooFiles/PATIENT.sql"
doctor_file_path = "../mockarooFiles/DOCTOR.sql"
dispense_file_path = "insert_dispensing.sql"
med_file_path = "insert_medications.sql"

patient_ids = extract_patient_ids(patient_file_path)
doctor_ids = extract_doctor_ids(doctor_file_path)
dispense_ids = extract_dispense_ids(dispense_file_path)
med_codes = extract_medication_codes(med_file_path)

# Fallbacks if files aren't found
if not patient_ids:
    patient_ids = ["942240577", "706039487"]
if not doctor_ids:
    doctor_ids = ["595434934", "448884348"]
if not dispense_ids:
    dispense_ids = list(range(1, 20001))
if not med_codes:
    med_codes = list(range(1000, 1500))

print(f"Loaded successfully: {len(patient_ids)} patients, {len(doctor_ids)} doctors, {len(dispense_ids)} dispensing records, and {len(med_codes)} medications!")

# 2. Open output SQL file for Prescriptions
with open('insert_prescriptions.sql', 'w', encoding='utf-8') as sql_file:
    
    sql_file.write("-- START OF 20,000 PRESCRIPTION RECORDS WITH FULL REAL FOREIGN KEYS\n\n")
    
    urgency_statuses = ["Routine", "Urgent", "Emergency"]
    prescription_statuses = ["Active", "Completed", "Cancelled", "Pending"]
    instructions_list = [
        "Take 1 tablet twice a day with food", 
        "Take 1 capsule every 8 hours", 
        "Apply thin layer on affected area 3 times daily", 
        "Inject 10 units subcutaneously before bedtime", 
        "Take 1 tablet as needed for pain"
    ]

    # 3. Generate 20,000 records
    for i in range(1, 20001):
        prescription_code = 50000 + i  
        date_issued = f"2026-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        dose_instructions = random.choice(instructions_list)
        quantity = random.randint(1, 30)
        urgency = random.choice(urgency_statuses)
        status = random.choice(prescription_statuses)
        
        patient_id = random.choice(patient_ids)
        doctor_id = random.choice(doctor_ids)
        med_code = random.choice(med_codes)
        
        # DispenseID can be NULL (if not dispensed yet) or chosen from actual loaded DispenseIDs
        if dispense_ids and random.choice([True, False]): # 50% chance to have a dispense ID or NULL
            dispense_id = random.choice(dispense_ids)
            dispense_val = str(dispense_id)
        else:
            dispense_val = "NULL"

        sql = (
            f"INSERT INTO PRESCRIPTION (PrescriptionCode, DateIssued, DoseInstructions, "
            f"QuantityRequested, UrgencyStatus, Status, PatientID, DoctorID, DispenseID, MedicationCode) "
            f"VALUES ({prescription_code}, '{date_issued}', '{dose_instructions}', {quantity}, "
            f"'{urgency}', '{status}', '{patient_id}', '{doctor_id}', {dispense_val}, {med_code});\n"
        )
        
        sql_file.write(sql)

print("Success! Regenerated 20,000 prescription records mapped to real dispensing IDs.")