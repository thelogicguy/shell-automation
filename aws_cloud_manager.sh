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

    count=2 # Number of instances to create
    region="us-east-1"

    # AMI IDs for different OS types

    ami_amazon_linux="ami-0abcdef1234567890" # Replace with actual Amazon Linux AMI ID
    ami_ubuntu="ami-0abcdef1234567891"       # Replace with actual Ubuntu AMI ID
    ami_centos="ami-0abcdef1234567892"       # Replace with actual CentOS AMI ID
    instance_type="t2.micro" # Example instance type, replace with actual type

     # User data script to install Apache on Amazon Linux
    user_data_amazon_linux="#!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd"

    # User data script to install Apache on Ubuntu
    user_data_ubuntu="#!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2"

    # User data script to install Apache on CentOS
    user_data_centos="#!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd"

    # Create Amazon Linux instances

    aws ec2 run-instances \
        --image-id "$ami_amazon_linux" \
        --instance-type "$instance_type" \
        --count $count \
        --key-name "darey.io.pem" \
	--security-group-ids sg-0b0384b66d7d692f9 \ # Replace with actual security group
        --region $region
    	--user-data "$user_data_amazon_linux"

    if [ $? -eq 0 ]; then

        echo "Amazon Linux EC2 instances created successfully."

    else

        echo "Failed to create Amazon Linux EC2 instances."

    fi

    # Create Ubuntu instances

    aws ec2 run-instances \
        --image-id "$ami_ubuntu" \
        --instance-type "$instance_type" \
        --count $count \
        --key-name "darey.io.pem" \
	--security-group-ids sg-0b0384b66d7d692f9 \ # Replace with actual securiy group
        --region $region
    	--user-data "$user_data_ubuntu"

    if [ $? -eq 0 ]; then

        echo "Ubuntu EC2 instances created successfully."

    else

        echo "Failed to create Ubuntu EC2 instances."

    fi


    # Create CentOS instances

    aws ec2 run-instances \
        --image-id "$ami_centos" \
        --instance-type "$instance_type" \
        --count $count \
        --key-name "darey.io.pem" \
	--security-group-ids sg-0b0384b66d7d692f9 \ # Replace with actual security group
        --region $region
    	--user-data "$user_data_centos"

    if [ $? -eq 0 ]; then

        echo "CentOS EC2 instances created successfully."

    else

        echo "Failed to create CentOS EC2 instances."

    fi
}


# Function to verify Apache service status on instances

verify_apache_status() {

    instance_ids=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text)

    for instance_id in $instance_ids; do
        public_dns=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicDnsName' --output text)

        ssh -o StrictHostKeyChecking=no -i "darey.io.pem" ec2-user@$public_dns "systemctl status httpd" &>/dev/null
        if [ $? -eq 0 ]; then
            echo "Apache is running on Amazon Linux instance $instance_id"
        else
            echo "Apache is not running on Amazon Linux instance $instance_id"
        fi

        ssh -o StrictHostKeyChecking=no -i "darey.io.pem" ubuntu@$public_dns "systemctl status apache2" &>/dev/null
        if [ $? -eq 0 ]; then
            echo "Apache is running on Ubuntu instance $instance_id"
        else
            echo "Apache is not running on Ubuntu instance $instance_id"
        fi

        ssh -o StrictHostKeyChecking=no -i "darey.io.pem" centos@$public_dns "systemctl status httpd" &>/dev/null
        if [ $? -eq 0 ]; then
            echo "Apache is running on CentOS instance $instance_id"
        else
            echo "Apache is not running on CentOS instance $instance_id"
        fi
    done
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

# Function to create users

create_iam_users() {

    # Creating an array of names for new employees

    new_employees=("Emmanuel" "Ayanfe" "Oyindamola" "Okeogene" "Wale")

    for employee in "${new_employees[@]}"; do

        if aws iam get-user --user-name "$employee" &>/dev/null; then

            echo "Username '$employee' already exists. Kindly replace with a unique username."

        else

            aws iam create-user --user-name "$employee"

            if [ $? -eq 0 ]; then

                echo "User '$employee' created successfully."

            else

                echo "Failed to create user '$employee'."

            fi

        fi

    done
}

# Function to create group

create_iam_group() {

    aws iam create-group --group-name "admin"

    if [ $? -eq 0 ]; then

        echo "'Admin Group' created successfully."

    else

        echo "Failed to create 'Admin Group'."

    fi
}

# Function to attach policy to group

attach_policy() {

    aws iam attach-group-policy --group-name "admin" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

    if [ $? -eq 0 ]; then

        echo "Successfully created and attached 'Administrator Policy' to 'Admin Group'."

    else

        echo "Failed to attach 'Administrator Policy'."

    fi
}

# Function to assign users to admin group

assign_to_group() {

    users=("Emmanuel" "Ayanfe" "Oyindamola" "Okeogene" "Wale")

    for user in "${users[@]}"; do

        aws iam add-user-to-group --user-name "$user" --group-name "admin"

        if [ $? -eq 0 ]; then

            echo "Successfully assigned user '$user' to group."

        else

            echo "Failed to assign user '$user' to group."

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
verify_apache_status
create_s3_buckets
create_iam_users
create_iam_group
attach_policy
assign_to_group
