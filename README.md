# Database Source and Sink Playground

This repository demonstrates how to set up a CDC (Change Data Capture) pipeline using Confluent Cloud and Terraform. It includes configurations for a source database (PostgreSQL) and a sink database (PostgreSQL) to enable data replication.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
2. A Confluent Cloud account with API keys.
3. Source and target PostgreSQL databases.

## Setup

### Environment Variables

Export the required environment variables before running Terraform:

```shell
export TF_VAR_confluent_cloud_api_key="CLOUD_API_KEY"
export TF_VAR_confluent_cloud_api_secret="CLOUD_API_SECRET"
export TF_VAR_db_source_host="DB_SOURCE_HOST"
export TF_VAR_db_source_password="DB_SOURCE_PASS"
export TF_VAR_db_target_host="DB_TARGET_HOST"
export TF_VAR_db_target_password="DB_TARGET_PASS"
```

### Initialize Terraform

Run the following commands to initialize and apply the Terraform configuration:

```shell
terraform init
terraform apply
```

## Resources Created

The Terraform configuration creates the following resources:

1. **Service Account**: A Confluent Cloud service account for managing resources.
2. **Environment**: A Confluent Cloud environment for the CDC pipeline.
3. **Kafka Cluster**: A single-zone Kafka cluster in AWS.
4. **Connectors**:
   - **Source Connector**: Captures changes from the source PostgreSQL database.
   - **Sink Connector**: Writes data to the target PostgreSQL database.

## Connector Configuration

### Source Connector

The source connector uses the `PostgresCdcSourceV2` class to capture changes from the source database. Key configurations include:
- `database.hostname`: Hostname of the source database.
- `database.user`: Username for the source database.
- `database.password`: Password for the source database.
- `topic.prefix`: Prefix for Kafka topics.

### Sink Connector

The sink connector uses the `PostgresSink` class to write data to the target database. Key configurations include:
- `connection.host`: Hostname of the target database.
- `connection.user`: Username for the target database.
- `connection.password`: Password for the target database.
- `topics`: Kafka topics to consume.

## Cleanup

To destroy the resources created by Terraform, run:

```shell
terraform destroy
```

## Notes

- Ensure that the `.gitignore` file excludes sensitive files like `terraform.tfstate` and `terraform.tfvars`.
- Use the `variables.tf` file to define additional variables as needed.

## Disclaimer

This repository is provided as a demo and should be used at your own risk. The authors are not responsible for any issues or damages caused by using this code.
