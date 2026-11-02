# Terraform AWS Scalable 3-Tier Web Application

A hands-on AWS infrastructure project that provisions a scalable 3-tier web application architecture using Terraform.

This project demonstrates AWS infrastructure provisioning, networking, load balancing, compute resources, auto scaling, and database connectivity using reusable Terraform modules.

The application consists of a frontend, backend REST API, and MySQL database hosted on Amazon RDS.

## Project Overview

The goal of this project is to build a scalable and modular AWS infrastructure using Infrastructure as Code (IaC).

### Architecture

```text
                         Internet
                            |
                     Frontend ALB
                            |
                   Frontend EC2 / ASG
                     (Nginx + UI)
                            |
                  Internal Backend ALB
                            |
                   Backend EC2 / ASG
                    (Node.js + Express)
                            |
                       Amazon RDS
                         MySQL
```

Supporting infrastructure includes:

- Custom AWS VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- Bastion Host
- EC2 Launch Templates
- Auto Scaling Groups
- Application Load Balancers
- Amazon RDS MySQL

## Technology Stack

| Category | Technology |
|---|---|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| Compute | Amazon EC2 |
| Networking | VPC, Subnets, IGW, NAT |
| Load Balancing | Application Load Balancer |
| Auto Scaling | EC2 Auto Scaling Groups |
| Frontend | HTML, CSS, JavaScript, Nginx |
| Backend | Node.js, Express.js |
| Database | MySQL, Amazon RDS |
| Remote State | Amazon S3 |
| Version Control | Git and GitHub |

## Repository Structure

```text
terraform-aws-scalable-web-platform/
|
|-- Roots/
|   |
|   |-- environments/
|   |   |
|   |   |-- dev/
|   |       |-- backend.tf
|   |       |-- main.tf
|   |       |-- outputs.tf
|   |       |-- providers.tf
|   |       |-- variables.tf
|   |       |-- terraform.tfvars
|   |
|   |-- modules/
|       |
|       |-- infrastructure/
|       |   |-- provider.tf
|       |   |-- vpc.tf
|       |   |-- security_group.tf
|       |   |-- variables.tf
|       |   |-- outputs.tf
|       |
|       |-- bastion/
|       |   |-- main.tf
|       |
|       |-- database/
|       |   |-- data.tf
|       |   |-- provider.tf
|       |   |-- rds.tf
|       |   |-- variable.tf
|       |
|       |-- frontend/
|       |   |
|       |   |-- ec2/
|       |   |-- launch-template/
|       |   |-- asg/
|       |   |-- loadbalancer-frontend/
|       |
|       |-- backend/
|           |
|           |-- ec2/
|           |-- launch-template/
|           |-- asg/
|           |-- loadbalancer-backend/
|
|-- application/
|   |
|   |-- backend/
|   |   |-- app.js
|   |   |-- package.json
|   |
|   |-- frontend/
|   |   |-- index.html
|   |
|   |-- deploy/
|       |-- backend.env.example
|       |-- backend.service
|       |-- deploy-backend.sh
|       |-- deploy-frontend.sh
|
|-- .editorconfig
|-- .gitignore
|-- LICENSE
|-- README.md
```



## AWS Infrastructure

### 1. Networking

The infrastructure module provisions the AWS networking components.

- Custom VPC with CIDR `10.0.0.0/16`
- Public and private subnets across Availability Zones
- Internet Gateway
- NAT Gateway
- Public and private route tables
- Subnet associations
- Security Groups

### 2. Frontend Layer

The frontend layer is responsible for serving the web application.

- Frontend Application Load Balancer
- Frontend EC2 instances
- Frontend Launch Template
- Frontend Auto Scaling Group
- Nginx web server

### 3. Backend Layer

The backend layer handles application logic and API requests.

- Internal Backend Application Load Balancer
- Backend EC2 instances
- Backend Launch Template
- Backend Auto Scaling Group
- Node.js and Express.js REST API

### 4. Database Layer

The database layer provides persistent storage.

- Amazon RDS MySQL
- Private database subnets
- Database connectivity from the backend
- Security Group access control on port 3306

### 5. Bastion Host

A Bastion Host provides an administrative access path to private EC2 instances when configured with the required network and security rules.

## Application Overview

The `application/` directory contains a sample Task Management application.

### Frontend

- Built using HTML, CSS and JavaScript.
- Provides a simple task management interface.
- Communicates with the backend using REST API requests.
- Uses `/api` as the API request path.

### Backend

- Built using Node.js and Express.js.
- Provides REST API endpoints.
- Connects to MySQL using the `mysql2` package.
- Handles task creation and retrieval.

### Database

- Amazon RDS MySQL.
- Stores application tasks.
- Provides persistent data storage.

### Application Request Flow

```text
User Browser
     |
     v
Frontend ALB
     |
     v
Frontend EC2 (Nginx)
     |
     |  /api requests
     v
Internal Backend ALB
     |
     v
Backend EC2 (Node.js)
     |
     v
Amazon RDS MySQL
```

## Application API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | /api/health | Backend health check |
| GET | /api/tasks | Retrieve all tasks |
| POST | /api/tasks | Create a new task |

## Prerequisites

Install and configure the following tools before starting:

- AWS Account
- AWS CLI
- Terraform
- Git
- Node.js
- AWS IAM permissions for the required resources

Verify installations:

```bash
terraform version
aws --version
git --version
node --version
```

Configure AWS credentials:

```bash
aws configure
```

Use an IAM user or role with appropriate permissions. Avoid using root account credentials for deployment.

## Terraform Deployment

All Terraform commands should be executed from the development environment directory.

### Step 1: Navigate to the Dev Environment

```bash
cd Roots/environments/dev
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Format Terraform Files

```bash
terraform fmt -recursive
```

### Step 4: Validate Configuration

```bash
terraform validate
```

### Step 5: Review Deployment Plan

```bash
terraform plan
```

Review the resources that Terraform intends to create before applying changes.

### Step 6: Deploy AWS Infrastructure

```bash
terraform apply
```

Confirm the deployment when prompted.

### Step 7: View Terraform Outputs

```bash
terraform output
```

Use the output values to identify the deployed AWS resources and endpoints.

## Application Deployment

The `application/` directory contains the frontend, backend, and deployment scripts.

Important: Terraform infrastructure provisioning and application deployment are currently separate steps. The application scripts support manual deployment on EC2 instances, including through AWS Systems Manager Session Manager. Automatic application deployment through Launch Template User Data must be configured separately before expecting `terraform apply` to deploy the application automatically.

### Backend Deployment

1. Copy the backend directory and deployment files to a backend EC2 instance.
2. Configure the backend environment file.
3. Add the RDS endpoint and database credentials.
4. Run the backend deployment script.

Example environment configuration:

```env
DB_HOST=your-rds-endpoint
DB_USER=your-db-username
DB_PASSWORD=your-db-password
DB_NAME=your-database-name
```

Keep actual database credentials private. Do not commit the real `.env` file to GitHub.

Run the deployment script:

```bash
sudo bash deploy-backend.sh
```

### Frontend Deployment

1. Copy the frontend directory and deployment script to a frontend EC2 instance.
2. Provide the internal Backend ALB DNS.
3. Run the frontend deployment script.

```bash
sudo bash deploy-frontend.sh "http://YOUR_INTERNAL_BACKEND_ALB_DNS"
```

This configures Nginx to serve the frontend and proxy `/api` requests to the internal Backend ALB.

## Security Configuration

The architecture uses Security Groups to control communication between application tiers.

| Source | Destination | Port |
|---|---|---|
| Internet | Frontend ALB | 80 |
| Frontend ALB | Frontend EC2 | 80 |
| Frontend EC2 | Backend ALB | 80 |
| Backend ALB | Backend EC2 | 8080 |
| Backend EC2 | RDS MySQL | 3306 |

Security best practices:

- Keep the backend ALB internal.
- Do not expose RDS publicly.
- Restrict EC2 inbound traffic using Security Groups.
- Allow database access only from the backend security group.
- Prefer AWS Systems Manager Session Manager for instance administration.
- Store database credentials in AWS Systems Manager Parameter Store or AWS Secrets Manager for production use.
- Use HTTPS with AWS Certificate Manager when configuring HTTPS listeners.

## Application Testing

After deploying the infrastructure and application, open the Frontend ALB DNS in your browser.

```text
http://YOUR_FRONTEND_ALB_DNS
```

Test the backend health endpoint:

```bash
curl http://YOUR_FRONTEND_ALB_DNS/api/health
```

Retrieve tasks:

```bash
curl http://YOUR_FRONTEND_ALB_DNS/api/tasks
```

Create a task:

```bash
curl -X POST http://YOUR_FRONTEND_ALB_DNS/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test AWS 3-Tier Application"}'
```

Refresh the frontend and verify that the created task remains available from the MySQL database.

## Terraform Remote State

The development environment contains a `backend.tf` file for remote Terraform state configuration.

When using Amazon S3 as the backend:

- Configure an existing S3 bucket.
- Use a unique state key.
- Enable bucket versioning.
- Configure appropriate bucket permissions.
- Use S3 state locking with `use_lockfile` when supported by the Terraform version.
- Never commit Terraform state files to GitHub.

## Destroy Infrastructure

To remove the Terraform-managed AWS resources:

```bash
cd Roots/environments/dev
terraform plan -destroy
terraform destroy
```

Review the destroy plan before confirming.

Warning: Destroying resources can result in permanent data loss. Back up important data before running this command.

## Future Improvements

Planned enhancements:

- Automatic application deployment through Launch Template User Data
- AWS Systems Manager Parameter Store or Secrets Manager integration
- HTTPS using AWS Certificate Manager
- CloudFront CDN
- CloudWatch monitoring and alarms
- Prometheus and Grafana monitoring
- CI/CD automation using Jenkins or GitHub Actions
- Separate development and production environments

## Learning Objectives

This project demonstrates practical experience with:

- AWS infrastructure provisioning
- Terraform modules and reusable configurations
- VPC and subnet architecture
- Public and private networking
- Internet Gateway and NAT Gateway
- Application Load Balancers
- EC2 Launch Templates
- Auto Scaling Groups
- Amazon RDS MySQL
- Linux-based application deployment
- Security Groups and network access control
- Terraform state management

## Author

**Rahil Gaddi**

Cloud and DevOps Engineer | AWS | Terraform | Linux | Jenkins

- GitHub: https://github.com/RahilGaddi
- LinkedIn: https://linkedin.com/in/rahilgaddi/

---

This project is developed for hands-on learning and practical implementation of AWS cloud infrastructure using Terraform.