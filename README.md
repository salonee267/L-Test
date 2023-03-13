# INTRODUCTION AND OBJECTIVE 
This repository contains code to upload a csv file to S3, read the content of this file (emails) and synchronize it with RDS database. This is used for deploying in two environments- staging and production using terraform.  

# REPO STRUCTURE AND HIGHER LEVEL CODE BRIEF

Details, uses and breif introduction of the files and folders are here:

1.  .github/workflows

	1.1 workflow_dispatch.yml - This is a GitHub Actions workflow file, which defines how to deploy code to different environments using Terraform.

    The workflow is triggered on push events on the higher-environments branch or manually triggered using  the workflow_dispatch event. 

    There are two jobs defined in the workflow: deploy-staging and deploy-prod, each responsible for    deploying to its respective environment. Each jobs consists of respective environment variables and AWS credentials required for deployment. The workflow uses     (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) and region (AWS_REGION) to authenticate  and configure the AWS CLI, and an S3 bucket name (S3_BUCKET_NAME) and object key (S3_OBJECT_KEY) to  store the Terraform state file.

    The workflow uses the actions/checkout@v2 action to check out the code and the hashicorp/   setup-terraform@v1 action to set up Terraform. The workflow installs Python dependencies using pip     install and sets up the AWS credentials using the aws-actions/configure-aws-credentials@v2 action.

    The workflow then initializes Terraform using the terraform init command, passing in the S3 bucket and  object key to configure the backend. It then runs terraform plan to generate an execution plan, and  terraform apply to apply the changes to the infrastructure.

    Finally, the workflow checks the outcome of the terraform plan step and exits with an error code if it  failed.

2.  lambda_function/

	2.1  connect_to_rds.py- This is a Python script for a Lambda function that inserts data from a CSV file stored in an S3 bucket into a MySQL database hosted on Amazon RDS. This script  imports necessary modules accessing environment variables and ther dependencies.
    
    It sets up variables for the RDS like endpoint details etc and retrieves from environment variables   using the os.environ. It then sets up a connection to the RDS instance using the pymysql.connect() method.
    
    As the script's main function, it attempts to retrieve the CSV file from the S3 bucket. It is then read and decoded using the csv.reader() and io.StringIO() methods. The script then executes an SQL query to insert each row of data into the MySQL database using a for       loop. 
    
    Finally, the script commits the changes to the database using conn.commit(), closes the database       connection using conn.close(), and prints a success message to the console. If an error occurs at any  point during the execution of the script, an error message is printed to the console.

3.  backend.tf- This is a Terraform configuration file that specifies the required version of Terraform     and sets up the backend and provider for an AWS infrastructure. 
    In our case we have configured the backend bucket information in environments section of repository and referenced the same in workflow.yml file for dynamic referencing to respective environments.

4.  demofile.csv - This is a demo csv file with a list of first name, laste name, phone, email etc. We are interested in knowing about the email field and have created our SQL query similarly

5.	lambda.tf - This is file to create a lambda function. It creates a ZIP archive from a specified directory using data resource.
    
    It then creates lambda function which is set to the zip file created in previous data resource. This references to "connect_rds" function existing in py file in lambda_fuction/ folder. It specifies the role for Lambda function to use, runtime, python version, timeout etc. The environment variables section consists of env variables related to RDS as our lambda code would require this to execute the function.
    
    The "aws_lambda_permission" grants permission to an S3 bucket to invoke the Lambda function. The function_name parameter specifies the ARN of the Lambda function that is being granted permission to and the source_arn parameter specifies the ARN of the S3 bucket that is being granted permission to invoke the function (which is specified using an AWS resource named aws_s3_bucket).

6.  my_table.sql.tpl - This is an SQL script that creates a table in a MySQL database. This is used by local-exec provisioner of rds.tf file once db is created. 

    It selects a MySQL database and creates a table with the name specified by the ${table_name} variable in it. The table has two columns: id and email. The id column is defined as an integer that is automatically incremented for each new row added to the table.

    The email column is defined as a string and NOT NULL constraint ensures that a value must be provided for thiscolumn when a new row is added to the table. The UNIQUE constraint ensures that each valuein this column must be unique across all rows in the table. Finally, the PRIMARY KEY constraint is defined on the id column. This constraint ensures that the id column is unique for each row in the table.

7. outputs.tf- This file creates output named "endpoint" that describes the endpoint for an RDS    database instance. This endpoint is used in lambda code to obtain connection to RDS 

8. prod.tfvars and staging.tfvars- A .tfvars file is a Terraform input variable file that allows us to set values for input variables used in a Terraform configuration. This is a plain text file that can be used to override default values of input variables or provide values for required input variables that are not specified in the Terraform configuration. I have created one .tfvars file per environment to reference it dynamically in yml for deployment

9. rds.tf- This Terraform code provisions an AWS RDS instance with a MySQL engine, creates a security group to allow inbound traffic, generates a SQL table creation script using a template file, and executes that script on the provisioned RDS instance.

    The data block defines a data source that generates a SQL table creation script by rendering the existing my_table.sql.tpl file. It substitutes values for the variables db_name and     table_name, which are passed in as input variables from the main Terraform configuration file.

    The "null_resource" block defines a resource that does not create any infrastructure but serves as a way to execute local action- like executing a shell command to connect to RDS instance and executing a MySQL script on the provisioned RDS instance

    This further creates an RDS instance resource with specified configurations. A security group (aws_security_group.rds_sec_grp) is also associated with the instance to allow inbound traffic on port 3306 (MySQL) as defined in "rds_sec_grp" resource
     

10. s3.tf- This Terraform code creates an S3 bucket and an S3 bucket notification configuration     that invokes a Lambda function whenever a new object is created in the S3 bucket that ends with the     ".csv" suffix.

    The aws_s3_bucket resource creates the S3 bucket with the specified name (bucket attribute) and     sets the Access Control List (ACL) to "private" (acl attribute). The versioning block enables   versioning for the bucket.

    The aws_s3_bucket_notification resource creates a new S3 bucket notification configuration with the     specified bucket attribute, which references the S3 bucket created in the previous resource block.  The lambda_function block configures the Lambda function that will be invoked by the notification.   It specifies the ARN of the Lambda function (lambda_function_arn attribute), sets the event types     that should trigger the notification (events attribute), and sets a filter on the object key prefix     and suffix (filter_prefix and filter_suffix attributes). In this case, the filter suffix is set to  ".csv" so the notification is only triggered for CSV files.

11. Variables.tf- A variables.tf file in Terraform is used to define input variables that can be    passed to a module. The variables used in all tf files reside here with a description that explains their purpose or how they are used.

# Workflow and Setup

# SETUP OF ENVIRONMENT AND PIPELINE
1. The Environment Secrets and variables have been configured in Environments section of the repository for each env- staging and production. Settings--> Environments-->Prod/staging. This consists of AWS Account Credentials like AWS Secret Access Key and AWS Key ID (used to connect to each account) This also contains environment variables like AWS Region to deploy resources and S3 backend bucket's name to store statefiile.
2. The .github/workflows/workflow_dispatch.yml contains the code for deployment to the two accounts. It consists of two jobs- Steps to deploy to staging and prod. Each job has been configured to operate to respective environments. The pipeline has been configured to get triggered "on push" action- ie. on any commit the pipeline should get automatically triggered.
3. backend.tf - This contains the configuration for terraform version and cloud provider to be used
4. Once the pipleine is triggered, the flow and logs can be viewed at Actions section of github.

# WORKFLOW OF CODE
1. Creation of resources- RDS, S3 and lambda have been created in files- rds.tf, s3.tf and lambda.tf. 
2. Create a CSV file in a S3 bucket with some random emails- This part is accomplished by s3.tf. This file creates an S3 bucket resource and S3 bucket notification configuration. Whenever we upload a csv file into s3, this is triggered.
3. As a pre-requisite, rds.tf has been created that creates rds resource with security group and uses my_table.sql.tpl to create a table with local-exec provisioner
4. For creating a script that reads S3 file and synchronizes it with RDS, there is a lambda function. This script exists in lambda_function/connect_to_rds.py. It connects to the existing RDS database and inserts data from a CSV file stored in S3 bucket into RDS.
 
