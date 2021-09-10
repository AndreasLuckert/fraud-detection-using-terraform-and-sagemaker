#!/bin/bash

set -e

## CUSTOM KERNEL CREATION
## ----------------------------------------------------------------

# Setting the proper user credentials
sudo -u ec2-user -i <<'EOF'
unset SUDO_UID

# Installing a separate conda installation via Miniconda
WORKING_DIR=/home/ec2-user/SageMaker/custom-miniconda
mkdir -p "$WORKING_DIR"
wget https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda"
rm -rf "$WORKING_DIR/miniconda.sh"

# Instantiating variables used to create the custom kernel
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="andreasluckert_custom_kernel"
PYTHON="3.8"

# Creating the custom kernel
conda create --yes --name "$KERNEL_NAME" python="$PYTHON"
conda activate "$KERNEL_NAME"

# Installing the default ipykernel required from SageMaker
pip install --quiet ipykernel

# Downloading the requirements.txt script from S3-Bucket/GitHub
export AWS_PROFILE=${aws_profile}
aws s3 cp 's3://${s3_bucket_on_start_and_create_lifecycle_scripts}/requirements.txt' requirements.txt
# wget https://raw.githubusercontent.com/andreasluckert/aws-sm-notebook-instance/main/scripts/requirements.txt

# Installing the Python libraries listed in the requirements.txt script
pip install --quiet -r requirements.txt

EOF