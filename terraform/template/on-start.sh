#!/bin/bash

set -e

## IDLE AUTOSTOP STEPS
## ----------------------------------------------------------------

## Setting the timeout (in seconds) for how long the SageMaker notebook can run idly before being auto-stopped
# -> e.g. 1800 s = 30 min since first deployment can take between 15 and 20 minutes which could then fail like so:
# "Error: error waiting for sagemaker notebook instance (aws-sm-notebook-instance) to create: unexpected state 'Failed', wanted target 'InService'. last error: %!s(<nil>)"
# Hint for solution under following link: https://yuyasugano.medium.com/machine-learning-infrastructure-terraforming-sagemaker-part-2-f2460a9a4663
IDLE_TIME=300

# Getting the autostop.py script from S3-Bucket/GitHub
echo "Fetching the autostop script..."
export AWS_PROFILE=${aws_profile}
aws s3 cp 's3://${s3_bucket_on_start_and_create_lifecycle_scripts}/autostop.py' autostop.py
# aws s3 cp s3://sm-on-start-and-create-lifecycle-scripts/autostop.py autostop.py
# wget https://raw.githubusercontent.com/andreasluckert/fraud-detection-using-terraform-and-sagemaker/master/terraform/template/autostop.py

# Using crontab to autostop the notebook when idle time is breached
echo "Starting the SageMaker autostop script in cron."
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python $PWD/autostop.py --time $IDLE_TIME --ignore-connections") | crontab -


## AWS Sagemaker instance init
cd /home/ec2-user/SageMaker
aws s3 cp s3://${function_bucket_name}-${aws_region}/fraud-detection-using-machine-learning/${function_version}/notebooks/sagemaker_fraud_detection.ipynb .
sed -i 's/fraud-detection-end-to-end-demo/${s3_bucket_model_training_data}/g' sagemaker_fraud_detection.ipynb


## CUSTOM CONDA KERNEL USAGE STEPS
## ----------------------------------------------------------------

# Setting the proper user credentials
sudo -u ec2-user -i <<'EOF'
unset SUDO_UID

# Setting the source for the custom conda kernel
WORKING_DIR=/home/ec2-user/SageMaker/custom-miniconda
source "$WORKING_DIR/miniconda/bin/activate"

# Loading all the custom kernels
for env in $WORKING_DIR/miniconda/envs/*; do
    BASENAME=$(basename "$env")
    source activate "$BASENAME"
    python -m ipykernel install --user --name "$BASENAME" --display-name "Custom ($BASENAME)"
done