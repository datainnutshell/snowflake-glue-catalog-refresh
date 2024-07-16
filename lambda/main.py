import json
import snowflake.connector
import os

def handler(event, context):
    print("Event received:")
    print(json.dumps(event))

    # Extract table name from the Glue event
    table = event['detail']['tableName']
    database = event['detail']['databaseName']
    
    # Snowflake connection parameters
    snowflake_account = os.environ['SNOWFLAKE_ACCOUNT']
    snowflake_user = os.environ['SNOWFLAKE_USER']
    snowflake_password = os.environ['SNOWFLAKE_PASSWORD']
    snowflake_database = os.environ['SNOWFLAKE_DATABASE']
    snowflake_role = os.environ['SNOWFLAKE_ROLE']
    snowflake_warehouse = os.environ['SNOWFLAKE_WAREHOUSE']

    # Snowflake query
    query = f"ALTER ICEBERG TABLE {database}.{table} REFRESH"
    
    print(f"Query to be executed {query}")

    with snowflake.connector.connect(
        user=snowflake_user,
        password=snowflake_password,
        account=snowflake_account,
        database=snowflake_database,
        role=snowflake_role,
        warehouse=snowflake_warehouse) as con:
        with con.cursor() as cur:
            result = cur.execute(query).fetchall()
            con.commit()
        print(f"Query executed successfully: {result}")