import pymysql
import json
import csv
import io
import boto3
import os

# RDS endpoint details
ENDPOINT = os.environ["ENDPOINT"]
PORT = os.environ["PORT"]
USR = os.environ["USR"]
REGION = os.environ["REGION"]
DBNAME = os.environ["DBNAME"]
PASSWORD = os.environ["PASSWORD"]
TABLE_NAME = os.environ["TABLE_NAME"]

# Connect to the RDS instance
try:
    conn = pymysql.connect(
        host=ENDPOINT,
        port=PORT,
        database=DBNAME,
        user=USR,
        password=PASSWORD
    )
    print("Connected to database successfully.")
except Exception as e:
    print("Error connecting to database: ", str(e))

def lambda_handler(event,context):
    # Execute SQL query
    try:
        s3 = boto3.resource('s3')
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        obj = s3.Object(bucket, key)
        try:
            data = obj.get()['Body'].read().decode('utf-8')
        except:
            data = obj.get()['Body'].read().decode('iso-8859-1')
        rows = csv.reader(io.StringIO(data))
        
        header = next(rows)  # skip header row
        column_index = header.index('email')
    except Exception as e:
        print("Error fetching CSV file from S3: ", str(e))
    
    try:
        with conn.cursor() as cur:
            for row in rows:
                cur.execute( f"INSERT INTO {TABLE_NAME} (email) VALUES ('{row[column_index]}')" )

            cur.execute(f"SELECT * FROM {TABLE_NAME}")
            rows = cur.fetchall()
            print("Number of rows retrieved: ", len(rows))
            for row in rows:
                print(row)   

        conn.commit()
        print("Data inserted successfully.")
    except Exception as e:
        print("Error executing SQL query: ", str(e))

    # Close the database connection
    try:
        conn.close()
        print("Database connection closed successfully.")
    except Exception as e:
        print("Error closing database connection: ", str(e))
