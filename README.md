# VLLM Terraform Automation

This repository contains Terraform configurations to automate the deployment of vLLM (Vector Language Model) infrastructure on AWS. It's designed to set up GPU-based instances for running large language models such as Qwen with proper auto-scaling, networking, and security configurations.

## Architecture Overview

The infrastructure deploys the following components:

- **VPC with public and private subnets**
- **GPU instances** (default: g5.xlarge)
- **Auto Scaling Group** for dynamic scaling of instances
- **Network Load Balancer** for traffic distribution
- **Security groups** for access control
- **AWS PrivateLink** for secure private connectivity

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0 or newer
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [Packer](https://www.packer.io/downloads) (for building custom AMIs)
- A GitHub account (for SSH key retrieval)

## Project Structure

```
.
├── main.tf                  # Main Terraform configuration
├── providers.tf             # AWS provider configuration
├── variables.tf             # Input variables
├── versions.tf              # Terraform version constraints
├── build-ami/               # AMI building resources
│   ├── images/              # Packer templates
│   ├── scripts/             # Setup scripts for AMI
│   └── ssh_keys/            # SSH keys for AMI access
└── modules/                 # Terraform modules
    ├── asg-vm/              # Auto Scaling Group setup
    ├── firewall/            # Security groups
    ├── independent-vm/      # Standalone VM setup
    ├── lb/                  # Load balancer configuration
    ├── machine_image/       # AMI selection
    ├── network/             # VPC and subnet setup
    ├── ssh/                 # SSH key management
    ├── ssh_key/             # GitHub SSH key retrieval
    └── vpc_es/              # VPC Endpoint Service (PrivateLink)
```

## Getting Started

### Option 1: Using Pre-built AMI

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd vllm/tf-automate
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Set your variables in a `terraform.tfvars` file:
   ```hcl
   aws_region = "ap-south-1"
   instance_type = "g5.xlarge"
   workload_name = "qwen-vllm"
   asg_max_instances = 2
   vpc_endpointservice_alternate_dns_name = "your-service.example.com"
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

### Option 2: Build Custom AMI (Recommended)

1. Navigate to the build-ami directory:
   ```bash
   cd build-ami
   ```

2. Place your public SSH key in the `ssh_keys/key.pub` file

3. Initialize and build the AMI with Packer:
   ```bash
   cd images
   packer init image.pkr.hcl
   packer build -var region=ap-south-1 -var instance_type=g5.2xlarge image.pkr.hcl
   ```

4. Note the AMI ID from the Packer output and use it in your Terraform configuration. ![](./build-ami/built-ami.png)

## Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region to deploy infrastructure | "ap-south-1" |
| `instance_type` | EC2 instance type for GPU instances | "g5.xlarge" |
| `workload_name` | Name prefix for resources | "qwen-vllm" |
| `custom_ami_id` | ID of custom AMI with vLLM pre-installed | "ami-9999999" |
| `asg_max_instances` | Maximum number of instances in Auto Scaling Group | 1 |
| `vpc_endpointservice_alternate_dns_name` | DNS name for PrivateLink endpoint | "" |

## Features

- **GitHub SSH Key Integration**: Automatically pulls your public SSH key from GitHub
- **Auto Scaling**: Scales based on demand with warm pool support
- **Mixed Instance Types**: Supports both on-demand and spot instances
- **PrivateLink**: Secure private access to vLLM endpoints
- **Dynamic Network Configuration**: Auto-configured VPC, subnets, and security groups

## AMI Configuration

The custom AMI includes:
- Ubuntu 24.04 (Noble)
- NVIDIA drivers
- CUDA toolkit
- Python 3.12 with vLLM installed
- Automatic startup configuration for vLLM serving

## Deployment Modes

1. **Independent VM**: Deploys a single GPU instance (when `custom_ami_id` is not specified)
2. **Auto Scaling Group**: Deploys a scalable group of instances (when `custom_ami_id` is specified)

## Security Features

- IMDSv2 required on all instances
- Encrypted EBS volumes
- Security groups with least privilege access
- SSH key-based authentication

## Output Values

- `instances_detail`: Details of deployed independent VM instances
- `asg_details`: Details of the Auto Scaling Group
- `lb_arn`: Load Balancer ARN
- `vpc_endpointservice`: VPC Endpoint Service information for PrivateLink setup

## License

[MIT License](LICENSE) (or specify your license)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.