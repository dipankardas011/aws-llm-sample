variable "workload_name" {
  description = "Name of the workload"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the VM"
  type        = string
  default     = "g5.2xlarge"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID for the VM"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the VM"
  type        = list(string)
}

variable "instance_category" {
  description = "Type of spot instance request"
  type        = string
  validation {
    condition     = contains(["on-demand", "spot"], var.instance_category)
    error_message = "instance_category must be either 'on-demand' or 'spot'."
  }
}

variable "ebs_size" {
  description = "Configuration for the root block device"
  type        = number
  default     = 120
}