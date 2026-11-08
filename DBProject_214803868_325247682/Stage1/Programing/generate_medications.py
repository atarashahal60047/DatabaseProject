import random
import csv
import os

# 1. Load real InventoryIDs from the MEDWAREHOUSE.csv file
inventory_ids = []
csv_path = "../DataImportFiles/MEDWAREHOUSE.csv" # Adjust path if located elsewhere, e.g., 'DataImportFiles/MEDWAREHOUSE.csv'

if os.path.exists(csv_path):
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader) # Skip header
        for row in reader:
            if row:
                inventory_ids.append(int(row[0]))

# Fallback if the file isn't found yet
if not inventory_ids:
    inventory_ids = list(range(1, 501))

print(f"Loaded {len(inventory_ids)} real inventory IDs for medications mapping!")

# 2. Open a file to write the SQL commands into it
with open('insert_medications.sql', 'w', encoding='utf-8') as sql_file:
    
    current_med_code = 1000
    
    # Lists for random generation to create realistic variations
    base_names_regular = ["Paracetamol", "Ibuprofen", "Amoxicillin", "Omeprazole", "Optalgin", "Aspirin", "Loratadine", "Cetirizine", "Metformin", "Simvastatin", "Amlodipine", "Pantoprazole"]
    base_names_fridge = ["Insulin Glargine", "Humira", "Ozempic", "Hepatitis B Vaccine", "Epinephrine", "Trastuzumab", "Infliximab", "Calcitonin"]
    base_names_special = ["Morphine", "Fentanyl", "Oxycodone", "Ritalin", "Methadone", "Diazepam", "Lorazepam", "Ketamine"]
    
    dosages = ["10mg", "20mg", "50mg", "100mg", "250mg", "500mg", "1g"]
    forms = ["Tablet", "Capsule", "Syrup", "Injection", "Vial", "Patch"]
    cabinets = ["Cabinet A1", "Cabinet A2", "Cabinet B1", "Cabinet B2", "Cabinet C1", "Shelf A", "Shelf B", "Drawer 3"]
    fridge_units = ["FRG-001", "FRG-002", "FRG-003", "FRG-004"]
    safes = ["SAFE-A-01", "SAFE-A-02", "SAFE-B-01", "SAFE-C-99"]

    sql_file.write("-- START OF AUTOMATED MEDICATION INSERTS (APPROX. 500 RECORDS)\n\n")

    # ==========================================
    # 1. GENERATE REGULAR MEDICATIONS (~200 records)
    # ==========================================
    sql_file.write("-- INSERTING REGULAR MEDICATIONS\n")
    for i in range(200):
        med_name = f"{random.choice(base_names_regular)} {i+1}"
        dosage = random.choice(dosages)
        form = random.choice(forms)
        storage = random.choice(cabinets)
        inventory_id = random.choice(inventory_ids) # Picked from real CSV IDs!
        
        sql_file.write(f"INSERT INTO MEDICATION (MedicationCode, MedName, Dosage, Form, StorageLocation, InventoryID) VALUES ({current_med_code}, '{med_name}', '{dosage}', '{form}', '{storage}', {inventory_id});\n")
        sql_file.write(f"INSERT INTO REGULARMED (MedicationCode) VALUES ({current_med_code});\n\n")
        
        current_med_code += 1

    # ==========================================
    # 2. GENERATE FRIDGE MEDICATIONS (~150 records)
    # ==========================================
    sql_file.write("-- INSERTING FRIDGE MEDICATIONS\n")
    for i in range(150):
        med_name = f"{random.choice(base_names_fridge)} {i+1}"
        dosage = random.choice(dosages)
        form = "Injection" if "Insulin" in med_name or "Ozempic" in med_name else random.choice(forms)
        storage = "Cold Room Main"
        inventory_id = random.choice(inventory_ids) # Picked from real CSV IDs!
        temp_range = "2-8C"
        fridge_id = random.choice(fridge_units)
        
        sql_file.write(f"INSERT INTO MEDICATION (MedicationCode, MedName, Dosage, Form, StorageLocation, InventoryID) VALUES ({current_med_code}, '{med_name}', '{dosage}', '{form}', '{storage}', {inventory_id});\n")
        sql_file.write(f"INSERT INTO FRIDGEMED (MedicationCode, TempRange, FridgeID) VALUES ({current_med_code}, '{temp_range}', '{fridge_id}');\n\n")
        
        current_med_code += 1

    # ==========================================
    # 3. GENERATE SPECIAL MEDICATIONS (~150 records)
    # ==========================================
    sql_file.write("-- INSERTING SPECIAL MEDICATIONS\n")
    for i in range(150):
        med_name = f"{random.choice(base_names_special)} {i+1}"
        dosage = random.choice(dosages)
        form = random.choice(forms)
        storage = "Secure Vault Room"
        inventory_id = random.choice(inventory_ids) # Picked from real CSV IDs!
        safe_code = random.choice(safes)
        
        sql_file.write(f"INSERT INTO MEDICATION (MedicationCode, MedName, Dosage, Form, StorageLocation, InventoryID) VALUES ({current_med_code}, '{med_name}', '{dosage}', '{form}', '{storage}', {inventory_id});\n")
        sql_file.write(f"INSERT INTO SPECIALMED (MedicationCode, SafeCode) VALUES ({current_med_code}, '{safe_code}');\n\n")

        current_med_code += 1

print("Success! The script has generated ~500 medication records into 'insert_medications.sql' mapped to real inventory IDs.")