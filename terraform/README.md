\# Terraform Infrastructure



This directory contains the Terraform configuration for the AWS 3-tier DevOps project.



\## Infrastructure Components



\- \*\*EC2\*\* — Application/server compute infrastructure.

\- \*\*IAM\*\* — IAM role and instance profile required for AWS Systems Manager.

\- \*\*SSM\*\* — Enables secure Session Manager access to the EC2 instance without SSH.

\- \*\*NAT Gateway\*\* — Provides outbound internet access for resources in private subnets.

\- \*\*Networking\*\* — Supports the public/private subnet architecture of the project.



\## AWS Region



The infrastructure is deployed in:



`eu-north-1` — Europe (Stockholm)



\## SSM Access



AWS Systems Manager Session Manager was successfully configured and tested with the EC2 instance.



Example:



```bash

aws ssm start-session --target <instance-id> --region eu-north-1

