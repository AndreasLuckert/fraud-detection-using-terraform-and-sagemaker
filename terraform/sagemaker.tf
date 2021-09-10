resource "aws_sagemaker_notebook_instance" "basic" {
  name                    = "FraudDetectionNotebookInstance"
  role_arn                = aws_iam_role.sm_notebook_instance_role.arn
  instance_type           = "ml.t2.medium"
  lifecycle_config_name   = aws_sagemaker_notebook_instance_lifecycle_configuration.basic_lifecycle.name
  default_code_repository = aws_sagemaker_code_repository.git_repo.code_repository_name

  tags = {
    Group     = var.default_resource_group
    CreatedBy = var.default_created_by
  }

  depends_on = [aws_s3_bucket_object.s3_fraud_detection_notebook]
}

data "template_file" "on_start" {
  template = file("${path.module}/template/on-start.sh")

  vars = {
    aws_profile                                     = var.aws_profile
    aws_region                                      = var.aws_region
    function_bucket_name                            = var.function_bucket_name
    function_version                                = var.function_version
    s3_bucket_on_start_and_create_lifecycle_scripts = var.s3_bucket_on_start_and_create_lifecycle_scripts
    s3_bucket_model_training_data                   = aws_s3_bucket.s3_bucket_model_training_data.id
  }
}

data "template_file" "on_create" {
  template = file("${path.module}/template/on-create.sh")

  vars = {
    aws_profile                                     = var.aws_profile
    s3_bucket_on_start_and_create_lifecycle_scripts = var.s3_bucket_on_start_and_create_lifecycle_scripts
  }
}
