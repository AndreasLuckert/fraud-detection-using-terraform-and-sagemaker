# Defining the SageMaker notebook lifecycle configuration
## FIXME: should not be uploaded in a GitHub repo, but rather to AWS CodeCommit (like the example below)
# resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "basic_lifecycle" {
#   name      = "dev-platform-al-sm-frauddetection-lifecycle-config"
#   on_create = filebase64("../template/on-create.sh")
#   on_start  = filebase64("../template/on-start.sh")
# }

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "basic_lifecycle" {
  name      = "dev-platform-al-sm-frauddetection-lifecycle-config"
  on_create = base64encode(data.template_file.on_create.rendered)
  on_start  = base64encode(data.template_file.on_start.rendered)

  depends_on = [aws_s3_bucket.s3_bucket_model_training_data]
}


# resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "basic_lifecycle" {
#   name     = "BasicNotebookInstanceLifecycleConfig"
#   on_start = base64encode(data.template_file.instance_init.rendered)

#   depends_on = [aws_s3_bucket.s3_bucket_model_training_data]
# }
