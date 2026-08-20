# AWS 3-Tier DevOps Infrastructure

Terraform configuration for a production-style **AWS 3-tier application architecture**.

The infrastructure separates the application into **Load Balancer, Application, and Database tiers**, with networking, security groups, IAM, and AWS Systems Manager managed through Terraform.

---

## 🏗️ Architecture

```text
                         Internet
                            │
                            ▼
                  ┌──────────────────┐
                  │  Application LB   │
                  │      (ALB)        │
                  └────────┬─────────┘
                           │ HTTP :80
                           ▼
              ┌─────────────────────────┐
              │     Application Tier    │
              │       EC2 Instance      │
              │   Amazon Linux / SSM    │
              └────────────┬────────────┘
                           │ PostgreSQL :5432
                           ▼
              ┌─────────────────────────┐
              │      Database Tier     │
              │     Amazon RDS         │
              │       PostgreSQL       │
              └─────────────────────────┘

        AWS VPC: 10.0.0.0/16

        ┌─────────────────────────────────────┐
        │              Public Tier             │
        │  Public Subnet A │ Public Subnet B  │
        │     AZ-a         │      AZ-b        │
        └─────────────────────────────────────┘

        ┌─────────────────────────────────────┐
        │          Database Subnets            │
        │ Database Subnet A │ Database Subnet B│
        │       AZ-a        │       AZ-b       │
        └─────────────────────────────────────┘
```

---

## ☁️ AWS Components

| Component                     | Purpose                                                  |
| ----------------------------- | -------------------------------------------------------- |
| **VPC**                       | Isolated AWS network for the application                 |
| **Public Subnets**            | Host the internet-facing ALB                             |
| **Application Subnet**        | Hosts the EC2 application server                         |
| **Database Subnets**          | Private subnets used by RDS                              |
| **Application Load Balancer** | Public entry point for application traffic               |
| **EC2**                       | Application/server compute                               |
| **RDS PostgreSQL**            | Managed relational database                              |
| **Security Groups**           | Control traffic between application tiers                |
| **NAT Gateway**               | Provides outbound internet access from private resources |
| **IAM**                       | Provides permissions required by EC2 and SSM             |
| **AWS Systems Manager**       | Secure shell access without SSH                          |
| **Terraform**                 | Infrastructure as Code                                   |

---

## 🔐 Security Architecture

The project uses separate security groups for each application tier.

### Load Balancer Tier

The ALB accepts HTTP traffic from the internet on:

```text
TCP 80
```

### Application Tier

The EC2 instance accepts HTTP traffic only from the ALB security group:

```text
ALB → EC2 : 80
```

The application server is therefore not intended to receive direct application traffic from the public internet.

### Database Tier

The PostgreSQL database accepts traffic from the application tier on:

```text
EC2 → RDS : 5432
```

The RDS instance is configured as:

```text
publicly_accessible = false
```

This keeps the database private inside the VPC.

---

## 🔄 Networking

The VPC uses:

```text
CIDR: 10.0.0.0/16
```

The infrastructure includes multiple subnets across Availability Zones.

### Public Subnets

```text
10.0.1.0/24 → Public Subnet A
10.0.4.0/24 → Public Subnet B
```

These provide the ALB with multi-AZ subnet placement.

### Application Subnet

```text
10.0.2.0/24 → Application Subnet
```

### Database Subnets

```text
10.0.3.0/24 → Database Subnet A
10.0.5.0/24 → Database Subnet B
```

The database subnet group uses both database subnets.

---

## ⚖️ Application Load Balancer

The Application Load Balancer provides the public entry point for the application.

It includes:

* Internet-facing ALB
* Two public subnets
* HTTP listener on port `80`
* Application target group
* EC2 target registration
* HTTP health checks
* Forwarding from ALB to the application instance

Health checks use:

```text
Path: /
Protocol: HTTP
Success codes: 200-399
```

---

## 🖥️ EC2 Application Server

The application tier uses an EC2 instance managed through Terraform.

The instance is integrated with **AWS Systems Manager** through IAM.

Instead of opening SSH access to the internet, Session Manager can be used:

```bash
aws ssm start-session --target <instance-id> --region eu-north-1
```

This provides secure administrative access without requiring an SSH key or publicly exposed SSH port.

---

## 🗄️ RDS PostgreSQL

The database tier uses Amazon RDS with PostgreSQL.

Current configuration includes:

```text
Engine: PostgreSQL
Version: 17
Instance: db.t3.micro
Storage: 20 GB
Storage Type: gp3
Encryption: Enabled
Public Access: Disabled
```

The RDS subnet group spans two database subnets.

> Note: The current RDS configuration uses `multi_az = false`. The database subnet group spans multiple Availability Zones, but the RDS instance itself is currently deployed as single-AZ.

---

## 🔑 Database Credentials

Database credentials are provided through Terraform variables:

```hcl
variable "db_username" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}
```

Sensitive files such as `terraform.tfvars` and Terraform state files should **never be committed to Git**.

---

## 🛠️ Terraform

Terraform is used to provision and manage the complete AWS infrastructure.

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform validate
```

### Create a Plan

```bash
terraform plan
```

### Apply Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

## 📁 Project Structure

```text
terraform/
│
├── alb.tf
├── ec2.tf
├── iam.tf
├── internet.tf
├── main.tf
├── nat.tf
├── networking.tf
├── provider.tf
├── rds.tf
├── routes.tf
├── security.tf
├── subnets.tf
├── variables.tf
│
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

### File Responsibilities

| File            | Responsibility                             |
| --------------- | ------------------------------------------ |
| `main.tf`       | Terraform configuration                    |
| `provider.tf`   | AWS provider configuration                 |
| `networking.tf` | VPC configuration                          |
| `subnets.tf`    | Public, application, and database subnets  |
| `routes.tf`     | Route table configuration                  |
| `internet.tf`   | Internet Gateway                           |
| `nat.tf`        | NAT Gateway                                |
| `security.tf`   | Tier-specific security groups              |
| `alb.tf`        | Application Load Balancer                  |
| `ec2.tf`        | Application EC2 instance                   |
| `rds.tf`        | PostgreSQL RDS infrastructure              |
| `iam.tf`        | IAM permissions and instance profile       |
| `variables.tf`  | Sensitive/configurable Terraform variables |

---

## 🌍 AWS Region

The project currently uses:

```text
eu-north-1
```

AWS region:

```text
Europe (Stockholm)
```

---

## 🔧 Technologies Used

* **AWS**
* **Terraform**
* **Amazon VPC**
* **Amazon EC2**
* **Application Load Balancer**
* **Amazon RDS**
* **PostgreSQL**
* **AWS IAM**
* **AWS Systems Manager**
* **NAT Gateway**
* **Git & GitHub**

---

## 📌 Current Status

The infrastructure currently includes:

* [x] AWS VPC
* [x] Public subnet architecture
* [x] Application subnet
* [x] Database subnet architecture
* [x] Multi-AZ subnet configuration
* [x] Internet Gateway
* [x] NAT Gateway
* [x] Tier-specific security groups
* [x] EC2 application server
* [x] IAM configuration
* [x] AWS Systems Manager access
* [x] Application Load Balancer
* [x] PostgreSQL RDS
* [x] Terraform Infrastructure as Code

---

## 🚀 Future Improvements

Planned improvements include:

* HTTPS/TLS termination on the ALB
* Auto Scaling Group for application instances
* RDS Multi-AZ deployment
* CloudWatch monitoring and logging
* Route 53 DNS configuration
* CI/CD pipeline integration
* Remote Terraform state using S3 and state locking
* Secrets Manager for database credentials
* Kubernetes deployment

---

## 👨‍💻 Project

**AWS 3-Tier DevOps Infrastructure**

Built as a hands-on DevOps learning project to practice:

```text
Infrastructure as Code
        ↓
AWS Networking
        ↓
Security
        ↓
Compute
        ↓
Load Balancing
        ↓
Database
        ↓
Systems Management
        ↓
DevOps Automation
```
