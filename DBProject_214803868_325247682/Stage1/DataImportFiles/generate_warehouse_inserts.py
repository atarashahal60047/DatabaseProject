import csv
import os

csv_filename = 'MEDWAREHOUSE.csv'
sql_filename = 'insert_medwarehouse.sql'

if not os.path.exists(csv_filename):
    print(f"Error: Could not find {csv_filename} in the current directory.")
else:
    with open(csv_filename, mode='r', encoding='utf-8') as csv_file, \
         open(sql_filename, mode='w', encoding='utf-8') as sql_file:
        
        csv_reader = csv.reader(csv_file)
        header = next(csv_reader) # Skip header row
        
        sql_file.write("-- START OF 500 MEDWAREHOUSE RECORDS INSERTS\n\n")
        
        count = 0
        for row in csv_reader:
            if not row:
                continue
            inventory_id = row[0]
            quantity_in_stock = row[1]
            minimum_threshold = row[2]
            batch_number = row[3]
            expiration_date = row[4]
            
            sql = (
                f"INSERT INTO MEDWAREHOUSE (InventoryID, QuantityInStock, MinimumThreshold, BatchNumber, ExpirationDate) "
                f"VALUES ({inventory_id}, {quantity_in_stock}, {minimum_threshold}, '{batch_number}', '{expiration_date}');\n"
            )
            sql_file.write(sql)
            count += 1
            
    print(f"Success! Generated {count} insert statements into '{sql_filename}'.")