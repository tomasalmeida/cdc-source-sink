terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.24.0"
    }
  }
}
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_service_account" "talmeida_sa-tf" {
  description  = "talmeida service account"
  display_name = "talmeida-sa-tf"
}

resource "confluent_role_binding" "talmeida-talmeida_sa_rbac-tf" {
  principal   = "User:${confluent_service_account.talmeida_sa-tf.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.talmeida_cdc_playground-tf.resource_name
}

resource "confluent_environment" "talmeida_cdc_playground-tf" {
  stream_governance {
    package = "ESSENTIALS"
  }
  display_name = "talmeida-cdc-playground-tf"
}

resource "confluent_kafka_cluster" "talmeida_cluster-tf" {
  availability = "SINGLE_ZONE"
  region       = "eu-central-1"
  environment {
    id = confluent_environment.talmeida_cdc_playground-tf.id
  }
  display_name = "talmeida-cluster-tf"
  cloud        = "AWS"
  basic {
  }
}

resource "confluent_connector" "talmeida_sink_postgres-tf" {
  status = "RUNNING"
  config_nonsensitive = {
    "auto.create"              = "true"
    "auto.evolve"              = "true"
    "connection.host"          = var.db_target_host
    "connection.port"          = "5432"
    "connection.user"          = "postgres"
    "connection.password"      = var.db_target_password
    "connector.class"          = "PostgresSink"
    "db.name"                  = "postgres"
    "delete.enabled"           = "true"
    "input.data.format"        = "AVRO"
    "input.key.format"         = "AVRO"
    "insert.mode"              = "UPSERT"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.talmeida_sa-tf.id
    "name"                     = "talmeida-sink"
    "pk.mode"                  = "record_key"
    "tasks.max"                = "1"
    topics                     = "people,users"
  }
  environment {
    id = confluent_environment.talmeida_cdc_playground-tf.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.talmeida_cluster-tf.id
  }
  depends_on = [
    confluent_connector.talmeida_cdc_postgres-tf
  ]
}

resource "confluent_connector" "talmeida_cdc_postgres-tf" {
  environment {
    id = confluent_environment.talmeida_cdc_playground-tf.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.talmeida_cluster-tf.id
  }
  status = "RUNNING"
  config_nonsensitive = {
    "after.state.only"                   = "true"
    "connector.class"                    = "PostgresCdcSourceV2"
    "database.dbname"                    = "postgres"
    "database.hostname"                  = var.db_source_host
    "database.port"                      = "5432"
    "database.user"                      = "postgres"
    "database.password"                  = var.db_source_password
    "kafka.auth.mode"                    = "SERVICE_ACCOUNT"
    "kafka.service.account.id"           = confluent_service_account.talmeida_sa-tf.id
    "name"                               = "talmeida-cdc"
    "output.data.format"                 = "AVRO"
    "output.key.format"                  = "AVRO"
    "tasks.max"                          = "1"
    "topic.prefix"                       = "cdc"
    transforms                           = "change_name"
    "transforms.change_name.regex"       = "cdc.public.(.*)"
    "transforms.change_name.replacement" = "$1"
    "transforms.change_name.type"        = "io.confluent.connect.cloud.transforms.TopicRegexRouter"
  } 
}