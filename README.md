aws logs tail /aws/lambda/write_and_retrieve_from_and_to_s3 --follow

curl -X POST "api-gateway-url/prod/write" \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello from Lambda"}'


curl -X GET "api-gateway-url/prod/read"


curl -X POST "https://your-api-url/prod/write" \
     -H "Content-Type: application/json" \
     -d '{"file_name": "example.json", "message": "Hello from Lambda"}'

curl -X GET "https://your-api-url/prod/read?file_name=example.json"


terraform output api_gateway_url


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

to compare costs from previous and current version:
```
infracost breakdown --path=tfplan.binary --project-name=cloudcuddler --out-file previous_version.json --format json
infracost diff --path=tfplan.binary --compare-to previous_version.json --project-name=cloudcuddler
```