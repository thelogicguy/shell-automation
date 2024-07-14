# PROJECT: SHELL SCRIPT FOR AWS IAM MANAGEMENT.

## Project Overview

This project is designed to automate the configuration and deployment of infrastructure environments using a bash script. The script handles environment selection (local, testing, or production), checks for necessary dependencies like the AWS CLI, and ensures the AWS profile is set correctly. Additionally, it automates the creation and management of various AWS resources including S3 buckets, EC2 instances, IAM users, and the deployment of the Apache web server on EC2 instances running different operating systems (Amazon Linux, Ubuntu, and CentOS).

## Configuration Details

### Prerequisites

- **AWS CLI**: Ensure AWS CLI is installed on your machine. If not, you can install it by following the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
- **AWS Profile**: Create and configure an AWS profile by running:
  ```sh
  aws configure --profile your-profile-name
SSH Key Pair: Ensure the key pair (darey.io.pem) exists and is accessible.
Script Usage
Set AWS_PROFILE
You can set the AWS profile environment variable in your shell session:
export AWS_PROFILE=your-profile-name
Or set it within the script itself:
export AWS_PROFILE=your-profile-name

Run the Script
The script requires one argument which specifies the environment (local, testing, or production). To run the script:
./script.sh <environment>

Script Details
Environment Argument: The script takes one argument to determine the environment configuration.
Dependency Checks: The script checks for the installation of AWS CLI and the presence of the AWS profile environment variable.
Script Functions:
create_s3_buckets: Creates S3 buckets for different departments.
create_ec2_instances: Launches EC2 instances with user data scripts to install and start Apache.
create_iam_users: Creates IAM users for new employees.
create_iam_group: Creates an IAM group named 'admin'.
attach_policy: Attaches the 'AdministratorAccess' policy to the 'admin' group.
assign_to_group: Assigns IAM users to the 'admin' group.
verify_apache_status: Checks the status of the Apache web server on each EC2 instance.
Challenges and Solutions
1. Argument Handling
Challenge: Ensuring the script receives the correct number of arguments.
Solution: Implemented a function to validate the number of arguments and provide usage instructions if incorrect.
2. Environment Validation
Challenge: Validating the environment argument to ensure it matches one of the predefined environments.
Solution: A function checks the value of the environment variable and provides appropriate feedback and error handling.
3. Dependency Checks
Challenge: Ensuring that the AWS CLI is installed and that the AWS profile is set.
Solution: Implemented functions to verify the presence of necessary dependencies and configurations, exiting the script with relevant messages if requirements are not met.
4. Handling Different Operating Systems
Challenge: Different operating systems require different commands to manage the Apache service.
Solution: Use conditional statements to run appropriate commands based on the OS.
5. User Data Script Limitations
Challenge: Ensuring that user data scripts execute correctly during instance initialization.
Solution: Test user data scripts separately on individual instances before integrating into the main script.
6. IAM User Uniqueness
Challenge: Avoiding conflicts with existing IAM usernames.
Solution: Check if a user exists before attempting to create it.
7. SSH Connectivity
Challenge: Ensuring successful SSH connections to newly created instances.
Solution: Retrieve the public DNS names of instances and use the correct SSH username for each OS.
Key Findings and Insights
Automation Efficiency: Automating resource creation and configuration significantly reduces manual effort and the potential for errors.
Scalability: The script can be easily scaled to handle more departments, users, and instances by simply modifying the arrays and configuration parameters.
Cross-OS Compatibility: By accommodating different operating systems, the script demonstrates versatility in managing diverse environments.
Error Handling: Effective error handling and conditional checks ensure the robustness of the script, making it reliable in various scenarios.
Automating Environment Configuration: Automating environment configuration through scripts significantly reduces manual errors and ensures consistency across different environments.
Dependency Management: It's crucial to check for necessary dependencies and configurations at the beginning of the script to avoid runtime errors.
User Feedback: Providing clear and immediate feedback to the user about missing arguments, dependencies, or incorrect environment values improves the usability and robustness of the script.
Conclusion
This project demonstrates the importance of automation in managing infrastructure configurations. By ensuring proper argument handling, dependency checks, and environment validation, the script provides a reliable and user-friendly way to manage different infrastructure environments. The additional functionalities for managing AWS resources and deploying Apache web servers further enhance the capabilities of the script, making it a comprehensive solution for cloud resource management.

