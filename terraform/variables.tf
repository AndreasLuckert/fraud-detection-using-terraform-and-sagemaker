# Default Tags
variable "default_resource_group" {
  description = "Default value to be used in resources' Group tag."
  default     = "fraud-detection"
}

variable "default_created_by" {
  description = "Default value to be used in resources' CreatedBy tag."
  default     = "terraform"
}

# AWS Settings
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_profile" {
  default = "ics_dev_power"
}

# Parameters
variable "function_bucket_name" {
  description = "Name of the S3 bucket hosting the code for fraud_detection Lambda function."
  default     = "fraud-detection-lambda-function-code"
}

variable "function_version" {
  description = "Version of the fraud_detection Lambda function to use."
  default     = "LATEST"
}

variable "s3_bucket_model_training_data" {
  description = "New bucket for storing the Amazon SageMaker model and training data."
  default     = "sm-model-and-training-data"
}

variable "s3_bucket_processed_events" {
  description = "New bucket for storing processed events for visualization features."
  default     = "sm-processed-events-for-visualization"
}

variable "s3_bucket_on_start_and_create_lifecycle_scripts" {
  description = "Bucket containing shell- and python scripts related to lifecycle management of AWS Sagemaker notebooks."
  default     = "sm-on-start-and-create-lifecycle-scripts"
}

variable "kinesis_firehose_prefix" {
  description = "Kinesis Firehose prefix for delivery of processed events."
  default     = "fraud-detection/firehose/"
}
