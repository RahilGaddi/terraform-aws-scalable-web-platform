# ─────────────────────────────
# INFRA 
# ──────────────────────────────

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = ""
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = ""
}
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = ""
}
variable "public_subnet_1_cidr" {
  description = "The CIDR block for the first public subnet"
  type        = string
  default     = ""
}
variable "public_subnet_2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
  default     = ""
}
variable "private_subnet_1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
  default     = ""
}
variable "private_subnet_2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
  default     = ""
}
variable "private_subnet_3_cidr" {
  description = "The CIDR block for the third private subnet"
  type        = string
  default     = ""
}
variable "private_subnet_4_cidr" {
  description = "The CIDR block for the fourth private subnet"
  type        = string
  default     = ""
}
variable "private_subnet_5_cidr" {
  description = "The CIDR block for the fifth private subnet"
  type        = string
  default     = ""
}
variable "private_subnet_6_cidr" {
  description = "The CIDR block for the sixth private subnet"
  type        = string
  default     = ""
}
variable "availability_zone_1a" {
  description = "The first availability zone"
  type        = string
  default     = ""
}
variable "availability_zone_1b" {
  description = "The second availability zone"
  type        = string
  default     = ""
}
variable "allowed_ssh_cidr" {
  description = "The CIDR block allowed to access the EC2 instances via SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ────────────────────────────
# frontend / backend /Bastion ec2 instance 
# ─────────────────────────────
variable "ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = ""
}
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = ""
}
variable "key_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
  default     = ""
}

# ─────────────────────────────
# RDS (DB Tier)
# ─────────────────────────────
variable "identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = ""
}
variable "db_name" {
  description = "The name of the RDS instance"
  type        = string
  default     = ""
}
variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  default     = ""
}
variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  default     = ""
}
