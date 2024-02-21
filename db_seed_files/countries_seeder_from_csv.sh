
#!/bin/bash
# Database connection variables
database_name="test_import_db"
table_name="countries"
host="localhost"
port="3306"  # Default MySQL port
username="root"
password="vicecity"

# CSV file to import from
csv_file="countries.csv"

# Function to parse CSV line properly
parse_csv_line() {
    local line="$1"
    local value=""
    local in_quotes=false
    local csv_columns=()

    for (( i=0; i<${#line}; i++ )); do
        local char="${line:$i:1}"
        if [ "$char" = '"' ]; then
            in_quotes=!$in_quotes
        elif [ "$char" = ',' ] && ! $in_quotes; then
            csv_columns+=("$value")
            value=""
        else
            value+="$char"
        fi
    done
    csv_columns+=("$value")  # Add the last value
    echo "${csv_columns[@]}"
}

# Determine if user wants to set table_columns and csv_columns variables
set_columns_manually=false

# If set_columns_manually is false, determine columns dynamically
if [ "$set_columns_manually" = false ]; then
    # Determine csv columns based on the first line of the CSV file
    # first_line=$(head -n 1 "$csv_file")
    # csv_columns_parsed=$(parse_csv_line "$first_line")
    # csv_columns_parsed_2=$(echo "$csv_columns_parsed" | tr ',' '\n' | awk '{print "col"NR}')
    # # echo $csv_columns_parsed_2
    # echo $csv_columns_parsed
    # exit
    # IFS= read -r -d '' -a csv_columns <<< "$csv_columns_parsed_2"
    # csv_columns="${csv_columns[@]}"

    # echo $csv_columns
    # exit

    first_line=$(head -n 1 "$csv_file")
    csv_columns_parsed=$(parse_csv_line "$first_line")
    IFS= read -r -d '' -a csv_columns <<< "$csv_columns_parsed"

    # Create csv columns in the format "col1", "col2", "col3", ...
    csv_columns=()
    for ((i=0; i<${#csv_columns_parsed[@]}; i++)); do
        csv_columns+=("col$((i+1))")
    done

    echo $csv_columns_parsed
    exit

    # # Determine csv columns based on the first line of the CSV file
    # first_line=$(head -n 1 "$csv_file")
    # IFS= read -r -d '' -a csv_columns < <(echo "$first_line" | tr ',' '\n' | awk '{print "col"NR}')
    # csv_columns="${csv_columns[@]}"

    # Create table columns based on csv columns
    table_columns=""
    for (( i=0; i<${#csv_columns[@]}; i++ )); do
        table_columns+="col$((i+1)):varchar,"
    done
    table_columns=${table_columns%,}  # Remove trailing comma
else
    # User manually sets columns
    csv_columns="col1,col2,col3"  # Example
    table_columns="id:int:auto_increment:primary_key,name:varchar,age:int"  # Example
fi

# Whether to drop the table before starting insertion (true/false)
drop_table=True

# Step 1: Drop the table if specified
if [ "$drop_table" = true ]; then
    mysql -h "$host" -P "$port" -u "$username" -p"$password" -e "DROP TABLE IF EXISTS $table_name" "$database_name"
    echo "Table $table_name dropped."
fi

# Step 2: Create table if it does not exist
# Loop over table columns to generate column definition
create_table_query="CREATE TABLE IF NOT EXISTS $table_name ("
IFS=',' read -ra columns <<< "$table_columns"
for column in "${columns[@]}"; do
    IFS=':' read -ra col_info <<< "$column"
    col_name="${col_info[0]}"
    col_type="${col_info[1]}"
    create_table_query+=" $col_name $col_type,"
done
create_table_query=${create_table_query%,}  # Remove trailing comma
create_table_query+=")"
mysql -h "$host" -P "$port" -u "$username" -p"$password" -e "$create_table_query" "$database_name"
echo "Table $table_name created or already exists."

# Step 3: Read CSV file and insert entries into the table in batches
# This loop reads the CSV file, splits each line into values based on the delimiter (assuming comma here), and inserts them into the table
counter=0
while IFS= read -r line; do
    # Handling quoted values containing commas
    values=()
    while IFS=, read -r -d '"' field; do
        values+=("$field")
        IFS=, read -r extra  # Read the comma after the quoted field
    done <<< "$line"

    # Constructing the insert query
    insert_query="INSERT INTO $table_name (${csv_columns}) VALUES ("
    for ((i=0; i<${#values[@]}; i++)); do
        insert_query+="'${values[$i]}',"
    done
    insert_query=${insert_query%,}  # Remove trailing comma
    insert_query+=")"

    # Executing the insert query
    mysql -h "$host" -P "$port" -u "$username" -p"$password" -e "$insert_query" "$database_name"

    # Increment counter and check if batch size reached
    ((counter++))
    if [ $((counter % batch_size)) -eq 0 ]; then
        echo "$counter entries inserted."
    fi
done < "$csv_file"

echo "All entries inserted."
