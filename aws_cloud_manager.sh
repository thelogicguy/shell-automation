#!/bin/bash

check_num_of_args() {
# checking the number of arguments
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <environment>"
	exit 1
fi

}

activate_infra_environment() {
# checking and acting on the environment variables
if [ "$ENVIRONMENT" == "local" ]; then
	echo "Running script for local environment..."
	# command for local environment
	
elif [ "$ENVIRONMENT" == "testing" ]; then
	echo "Running script for testing environment..."
        # command for testing environment
	
elif [ "$ENVIRONMENT" == "production" ]; then
	echo "Running script for production environment..."
	# command for production environment

else
	echo "Invalid environment specified. Please use 'local', 'testing', or 'production'"
exit 2

fi
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it before proceeding."
        return 1
    fi
}

# Function to check if AWS profile is set
check_aws_profile() {
    if [ -z "$AWS_PROFILE" ]; then
        echo "AWS profile environment variable is not set."
        return 1
    fi
}

# Function to create EC2 instances

create_ec2_instances() {

	# Specify the parameter for ec2 instances
	
	instance_type="t2.micro"
	ami_id="ami-04a81a99f5ec58529"
	count=2 # Number of instances to create
	region="us-east-1"

	# Create the EC2 instances
	
	aws ec2 run-instances \
		--image-id "$ami_id" \
		--instance-type "$instance_type" \
		--count $count \
		--key-name "darey.io" \
		--region $region

	# Check if the ec2 instances were created sucessfully.
	
	if [ $? -eq 0 ]; then

		echo "EC2 instances created successfully."

	else
		echo "Failed to create ec2 instances."

	fi

}

# Function to create s3 buckets for different departments

create_s3_buckets() {

	# Define company's name as prefix.
	company="keystonebank"

	# Array of department names
	departments=("customer-experience" "corporate-communications" "corporate-services" "legal-services" "compliance")

	# Loop through the array and create s3 buckets for each department.
	
	for department in "${departments[@]}"; do
		bucket_name="${company}-${department}-data-bucket"

	# Check if bucket already exists
	
	if aws s3api head-bucket --bucket "$bucket_name" &>/dev/null; then
		echo "S3 bucket "$bucket_name" already exist."

	else

	# Create S3 bucket using AWS cli
	
	aws s3api create-bucket \
		--bucket "$bucket_name" \
		--region us-east-1

	if [ $? -eq 0 ]; then
		echo "S3 bucket '$bucket_name' created successfully."

	else
	
		echo "Failed to create S3 bucket '$bucket_name'."

	fi

	fi

	done

}

# Accessing the first argument
ENVIRONMENT=$1

check_num_of_args "$@"  # Pass all arguments to check_num_of_args
activate_infra_environment
check_aws_cli
check_aws_profile
create_ec2_instances
create_s3_buckets
