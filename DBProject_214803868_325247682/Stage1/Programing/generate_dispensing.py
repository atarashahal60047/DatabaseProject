import random

# Open a file to write the SQL commands into it
with open('insert_dispensing.sql', 'w', encoding='utf-8') as sql_file:
    
    sql_file.write("-- START OF 20,000 DISPENSING RECORDS INSERTS\n\n")
    
    # Realistic lists for data generation
    pharmacist_names = [
        "Avi Cohen", "Rachel Levi", "David Mizrahi", "Noa Friedman", 
        "Yossi Peretz", "Sarah Goldberg", "Moshe Azulay", "Tamar Klein", 
        "Daniel Ben-David", "Michal Avraham", "Eitan Katz", "Yael Shapira"
    ]
    
    dispense_statuses = ["Completed", "Pending Verification", "Partially Dispensed", "Ready for Pickup", "Cancelled"]

    # Generate 20,000 records
    for i in range(1, 20001):
        dispense_id = i  # Unique ID from 1 to 20000
        pharmacist_name = random.choice(pharmacist_names)
        
        # Random realistic date in 2026
        dispense_date = f"2026-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
        
        # Quantity dispensed (logical amount, e.g., 1 to 30)
        quantity_dispensed = random.randint(1, 30)
        
        status = random.choice(dispense_statuses)

        # Build the INSERT statement
        sql = (
            f"INSERT INTO DISPENSING (DispenseID, PharmacistName, DispenseDate, QuantityDispensed, DispenseStatus) "
            f"VALUES ({dispense_id}, '{pharmacist_name}', '{dispense_date}', {quantity_dispensed}, '{status}');\n"
        )
        
        sql_file.write(sql)

print("Success! Generated 20,000 dispensing records into 'insert_dispensing.sql'.")