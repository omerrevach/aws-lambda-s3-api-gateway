# AWS Lambda with API Gateway and S3

## This project demonstrates an AWS Lambda function that interacts with an S3 bucket through the API Gateway. The infrastructure is provisioned using Terraform

## Features
- A lambda function that:
    - Handles POST requests to write data to an s3 bucket
    - Handles GET requests to retrieve data from the s3 bucket
- A s3 bucket that is restricted to allow only the lambda function to read/write
- API gateway to expose endpoints for the lambda function for read and write  executions
- A python script "run.py" to test the api gateway by making POST and GET requests

## Flow
1. A user makes a request to the api gateway
2. The api gateway recieves the request
3. The api gateway triggers/invokes the lambda function
4. The lambda function processes the request:
    - If it is a POST request then:
      - The request must contain a file_name as a query parameter
      - The request body (JSON) is stored in the specified file_name inside the S3 bucket
    - If it is a GET request then:
      - The request must contain a file_name as a query parameter
      - The Lambda function retrieves the file from the S3 bucket and returns its contents
5. The response is sent back to the user

## Infrustructure overiew with Terraform
- S3 bucket: stores data and is restricted to lambda only access
- IAM role and policy: grants permissions for lambda function to write to and read from S3
- Lambda Function:
    - Reads the request body and writes it to s3
    - Retrieves data from s3 when requested
- API Gateway:
    - Exposes two endpoints:
        - POST /write?file_name=yourfile.json -> stores data in s3
        - GET /read?file_name=yourfile.json -> retrieves data from s3


## Setup Instructions
1. **Prerequisites**
- Ensure these are installed or configured correctly:
    - AWS CLI with correct credentials and permissions
    - Terraform
    - Python 3.11+

2. **Git clone or unzip**
- If you want to clone from github then:
    ```
    git clone https://github.com/omerrevach/aws-lambda-s3-api-gateway.git
    ```
- If you want to use the zip:
    ```
    unzip submission.zip
    ```


3. **Deploy the infrustructure:**
    ```
    cd tf
    terraform init
    terraform apply -auto-approve
    ```

4. **Checking POST and GET requests**
use the "run.py"  to test the api gateway and make sure it is functioning correctly:
    ```
    python3 run.py
    ```
    or run in pychrm it is easier.
    
    >**Output**: {'message': 'Data written to data.json'}
    {'message': 'Hello World'}



## Troubleshooting
If lambda code fails check the logs to understand the error
```
aws logs tail /aws/lambda/write_and_retrieve_from_and_to_s3 --follow
```


## FinOps
To watch over the aws resources costs and make sure they are no too high

```
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
```

After it finished installing run:
```
infracost auth login
infracost configure get api_key
```

now to get costs to see before apllying infrustructure:
```
terraform install
terraform plan -out=tfplan.binary
infracost breakdown --path=tfplan.binary --project-name=wiz
```
