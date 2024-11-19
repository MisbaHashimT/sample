variable "vpc_ipv4_cidr" {
  description = "VPC CIDR block"
  type        = string
  default = "192.168.0.0/24"
}
variable "public_subnet_cidr" {
  description = "Public Subnet CIDR block"
  type        = string
  default = "192.168.0.0/26"
}
variable "public_subnet2_cidr" {
  description = "Public Subnet CIDR block"
  type        = string
  default = "192.168.0.64/26"
}
variable "private_subnet_cidr" {
  description = "Private Subnet CIDR block"
  type        = string
  default = "192.168.0.128/26"
}
variable "availability_zone" {
  description = "Avaliability zone"
  type        = string
  default     = "us-east-2a"
}
variable "availability_zone_2" {
  description = "Avaliability zone"
  type        = string
  default     = "us-east-2b"
}
variable "environment" {
  description = "Prod environment"
  type        = string
  default     = "prod"
}
variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
  default     = "ami-0490fddec0cbeb88b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "key-ohio"
}

variable "root_volume_size" {
  description = "Root volume size for instances"
  type        = number
  default     = 15
}

variable "additional_volume_size" {
  description = "Additional volume size for instances"
  type        = number
  default     = 15
}
variable "volume_type_ebs" {
  description = "volume type"
  type        = string
  default     = "gp2"
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling group"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling group"
  type        = number
  default     = 1
}

# variable "sg_ingress_rules" {
#   description = "List of ingress rules for the EC2 instance security group"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     security_groups = list(string) # Use only for SG to SG communication
#   }))
# }

# variable "lb_ingress_rules" {
#   description = "List of ingress rules for the load balancer security group"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
  
# }
