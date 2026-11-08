import random
import csv
import os

# 1. Load real InventoryIDs from MEDWAREHOUSE.csv
inventory_ids = []
csv_path = "MEDWAREHOUSE.csv"

if os.path.exists(csv_path):
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader) # Skip header
        for row in reader:
            if row:
                inventory_ids.append(int(row[0]))

# Fallback if needed
if not inventory_ids:
    inventory_ids = list(range(1, 501))

# DispenseIDs range from 1 to 20000 based on our DISPENSING table
dispense_ids = list(range(1, 20001))

# 2. Open output SQL file
with open('insert_drawn_from.sql', 'w', encoding='utf-8') as sql_file:
    sql_file.write("-- START OF DRAWN_FROM RELATIONSHIP RECORDS INSERTS (500 RECORDS)\n\n")
    
    # Use a set to keep track of generated pairs to prevent primary key duplication
    generated_pairs = set()
    
    count = 0
    while count < 500:
        dispense_id = random.choice(dispense_ids)
        inventory_id = random.choice(inventory_ids)
        
        pair = (dispense_id, inventory_id)
        if pair not in generated_pairs:
            generated_pairs.add(pair)
            
            sql = f"INSERT INTO DRAWN_FROM (DispenseID, InventoryID) VALUES ({dispense_id}, {inventory_id});\n"
            sql_file.write(sql)
            count += 1

print(f"Success! Generated {count} relationship records into 'insert_drawn_from.sql'.")