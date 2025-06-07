# Serverless Data Pipeline on AWS

## Project Summary

This project demonstrates a **real-world serverless data pipeline** built on AWS — from ingestion to transformation to analytics — using scalable, secure, and automated infrastructure. It simulates an end-to-end solution for ingesting raw data, transforming it in real-time using AWS Lambda, cataloging it via AWS Glue, and querying it using Athena.

This implementation reflects the type of system I'd design as an **AWS DevOps Engineer** to support big data applications, proof-of-concept pipelines, and event-driven architectures in a cloud-native environment.

---

## What This Project Demonstrates

| Capability | Description |
|------------|-------------|
| **AWS Cloud Infrastructure** | Deployed using Terraform: S3, Lambda, IAM, Glue, Athena |
| **Serverless Data Processing** | Event-driven transformation of raw CSV data with Lambda |
| **Infrastructure as Code (IaC)** | Fully automated provisioning using Terraform |
| **Big Data Analytics** | Use of AWS Glue + Athena to query processed datasets |
| **Automation & CI/CD** | GitHub Actions to auto-deploy Lambda updates |
| **Secure & Observable** | IAM roles, CloudWatch logs, and limited-permission Lambda execution |

---

## Key Technologies

- **AWS Services**: Lambda, S3, Glue, Athena, IAM, CloudWatch
- **IaC**: Terraform
- **CI/CD**: GitHub Actions
- **Languages**: Python (Lambda ETL), HCL (Terraform)
- **Security**: Role-based access with scoped permissions
- **Monitoring**: Logs via AWS CloudWatch

---

## How It Works

1. A user uploads a `.csv` file to an **S3 bucket**.
2. An **S3 event triggers a Lambda function** that performs a simple data transformation (removes rows with missing values).
3. The cleaned data is saved in a separate folder in S3 (`/processed/`).
4. An **AWS Glue crawler** automatically catalogs the processed data on a schedule.
5. **Athena** is configured to run SQL queries on the structured, processed dataset.
6. All AWS resources are provisioned and version-controlled using **Terraform**.
7. **GitHub Actions** is used to deploy Lambda changes on push.

## WorkFlow

[S3 Upload] --> [Lambda] --> [S3 Processed Folder] --> [Glue Crawler] --> [Athena]

---

## Project Structure

├── terraform/
├── lambda/
├── .github/workflows/
├── data/
├── README.md

---

## Example Use Case

**Use case**: A data science team needs an automated data ingestion and cleaning pipeline for ad hoc CSV uploads.

- They drop raw files in an S3 bucket.
- Within seconds, the data is cleaned, cataloged, and queryable via Athena.
- No servers, no cron jobs — all event-driven and serverless.

---

## Setup Instructions

### 1. Build and Package Lambda

```bash
cd lambda
pip install -r requirements.txt -t .
zip -r lambda.zip . -x "__pycache__/*"
```
Or just run the helper:
```
./build.sh
```

### 2. Deploy infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### 3. Upload Data and Trigger the Pipeline

Upload **sample_input.csv** to the S3 bucket (terraform output will show the name). The Lambda function will process it and store the output in the **/processed/** folder.

#### Athena Query Example
Once the Glue crawler has run and cataloged your data, run this query in Athena:
```
SELECT * FROM serverless_pipeline_db.processed_data LIMIT 10;
```
---

#### IAM & Security Notes

- Lambda execution role has only GetObject/PutObject to specific S3 paths.
- CloudWatch logging is enabled.
- Glue crawler role is scoped to only access the processed folder.

---

#### Future Enhancements
- Enable partitioning in Glue to support larger datasets
- Add alerting via SNS for pipeline failures
- Extend ETL logic to perform complex transformations
- Add CloudWatch Dashboard and Prometheus Exporter
---
