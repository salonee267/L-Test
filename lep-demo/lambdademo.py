# Define the code for the Lambda function
 import csv
 import os
 import boto3
 import pymysql
 # Configuration options
 S3_BUCKET_NAME = 'my-s3-bucket'
 S3_OBJECT_KEY = 'my-csv-file.csv'
 RDS_HOST = 'my-rds-host.amazonaws.com'
 RDS_PORT = 3306
 RDS_USER = 'my-rds-username'
 RDS_PASSWORD = 'my-rds-password'
 RDS_DATABASE = 'my-rds-database'
 # Create S3 and RDS clients
 s3 = boto3.client('s3')
 rds = pymysql.connect(host=RDS_HOST, port=RDS_PORT, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)
 def lambda_handler(event, context):
     # Download the CSV file from S3
     s3.download_file(S3_BUCKET_NAME, S3_OBJECT_KEY, '/tmp/my-csv-file.csv')
     # Parse the CSV file and update the RDS database
     with open('/tmp/my-csv-file.csv', newline='') as csvfile:
         reader = csv.reader(csvfile)
         next(reader)  # skip header row
         for row in reader:
             cursor = rds.cursor()
             cursor.execute('INSERT INTO my_table (col1, col2, col3) VALUES (%s, %s, %s)', (row[0], row[1], row[2]))
             rds.commit()
             cursor.close()
     # Return success
     return {
         'statusCode': 200,
         'body': 'CSV file successfully processed'
     }
 }