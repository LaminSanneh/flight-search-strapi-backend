#!/usr/bin/env python3

import csv
import mysql.connector

# Database connection variables
database_name="test_import_db"
table_name="countries"
host="localhost"
port="3306"  # Default MySQL port
username="root"
password="vicecity"

# CSV file to import from
csv_file = "countries.csv"

# Determine if user wants to set table_columns and csv_columns variables
set_columns_manually = False

# Function to parse CSV line properly
def parse_csv_line(line):
    value = ""
    in_quotes = False
    csv_columns = []

    for char in line:
        if char == '"':
            in_quotes = not in_quotes
        elif char == ',' and not in_quotes:
            csv_columns.append(value)
            value = ""
        else:
            value += char

    csv_columns.append(value)  # Add the last value
    return csv_columns

# If set_columns_manually is False, determine columns dynamically
if not set_columns_manually:
    # Determine csv columns based on the first line of the CSV file
    with open(csv_file, newline='') as csvfile:
        first_line = csvfile.readline().strip()
        csv_columns = ["col" + str(i + 1) for i in range(len(parse_csv_line(first_line)))]

    # Create table columns based on csv columns
    table_columns = ", ".join(f"{csv_column} VARCHAR(255)" for csv_column in csv_columns)
else:
    # User manually sets columns
    csv_columns = ["col1", "col2", "col3"]  # Example
    table_columns = "id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT"  # Example

# Whether to drop the table before starting insertion (True/False)
drop_table = True

# Step 1: Drop the table if specified
if drop_table:
    connection = mysql.connector.connect(host=host, port=port, user=username, password=password, database=database_name)
    cursor = connection.cursor()
    cursor.execute(f"DROP TABLE IF EXISTS {table_name}")
    print(f"Table {table_name} dropped.")
    connection.commit()
    connection.close()

# Step 2: Create table if it does not exist
connection = mysql.connector.connect(host=host, port=port, user=username, password=password, database=database_name)
cursor = connection.cursor()
cursor.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({table_columns})")
print(f"Table {table_name} created or already exists.")
connection.commit()

# Step 3: Read CSV file and insert entries into the table
with open(csv_file, newline='') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader)  # Skip header if present

    # Calculate dynamic batch size
    num_entries = sum(1 for _ in csvreader)
    recommended_batch_size = max(num_entries // 10, 1)  # Recommended batch size as 10% of total entries
    batch_size = recommended_batch_size

    csvfile.seek(0)  # Reset file pointer to beginning

    counter = 0
    entries_to_insert = []
    for row in csvreader:
        values = row
        entries_to_insert.append(values)

        # Insert entries in batches
        if len(entries_to_insert) >= batch_size:
            insert_query = f"INSERT INTO {table_name} ({', '.join(csv_columns)}) VALUES ({', '.join(['%s' for _ in values])})"
            cursor.executemany(insert_query, entries_to_insert)
            connection.commit()
            counter += len(entries_to_insert)
            entries_to_insert = []

            print(f"{counter} entries inserted.")

    # Insert any remaining entries
    if entries_to_insert:
        insert_query = f"INSERT INTO {table_name} ({', '.join(csv_columns)}) VALUES ({', '.join(['%s' for _ in values])})"
        cursor.executemany(insert_query, entries_to_insert)
        connection.commit()
        counter += len(entries_to_insert)
        print(f"{counter} entries inserted.")

connection.close()
print("All entries inserted.")
