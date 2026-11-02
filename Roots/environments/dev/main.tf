# ─────────────────────────────
# INFRA 
# ──────────────────────────────
module "infrastructure" {
  source                = "../../modules/infrastructure"
  aws_region            = var.aws_region
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  private_subnet_3_cidr = var.private_subnet_3_cidr
  private_subnet_4_cidr = var.private_subnet_4_cidr
  private_subnet_5_cidr = var.private_subnet_5_cidr
  private_subnet_6_cidr = var.private_subnet_6_cidr
  availability_zone_1a  = var.availability_zone_1a
  availability_zone_1b  = var.availability_zone_1b
  allowed_ssh_cidr      = var.allowed_ssh_cidr
}

# ────────────────────────────
# frontend ec2 instance 
# ─────────────────────────────

module "frontend" {
  source            = "../../modules/frontend/ec2"
  aws_region        = var.aws_region
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.infrastructure.private_web_subnets[0]
  security_group_id = module.infrastructure.frontend_server_sg_id
}

# ────────────────────────────
# backend ec2 instance public
# ─────────────────────────────

module "backend" {
  source            = "../../modules/backend/ec2"
  aws_region        = var.aws_region
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.infrastructure.private_app_subnets[0]
  security_group_id = module.infrastructure.backend_server_sg_id
}

# ────────────────────────────
# AWS Bastion Host
# ─────────────────────────────

module "bastion" {
  source            = "../../modules/bastion"
  aws_region        = var.aws_region
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.infrastructure.public_subnets[0]
  security_group_id = module.infrastructure.bastion_sg_id
}

# ─────────────────────────────
# RDS (DB Tier)
# ─────────────────────────────

module "database" {
  source         = "../../modules/database"
  aws_region     = var.aws_region
  identifier     = var.identifier
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  db_subnet_1_id = module.infrastructure.private_db_subnets[0]
  db_subnet_2_id = module.infrastructure.private_db_subnets[1]
  rds_sg_id      = module.infrastructure.database_sg_id
}

# ─────────────────────────────
# Frontend ALB
# ─────────────────────────────

module "frontend-alb" {
  source            = "../../modules/frontend/loadbalancer-frontend"
  aws_region        = var.aws_region
  vpc_id            = module.infrastructure.vpc_id
  subnets           = module.infrastructure.private_web_subnets
  security_group_id = module.infrastructure.alb_frontend_sg_id
  alb_name          = "frontend-alb"
  target_group_name = "frontend-tg"
}

# ─────────────────────────────
# Backend ALB
# ─────────────────────────────

module "backend-alb" {
  source            = "../../modules/backend/loadbalancer-backend"
  aws_region        = var.aws_region
  vpc_id            = module.infrastructure.vpc_id
  subnets           = module.infrastructure.private_app_subnets
  security_group_id = module.infrastructure.alb_backend_sg_id
  alb_name          = "backend-alb"
  target_group_name = "backend-tg"
}

# ─────────────────────────────
# Frontend Launch Template
# ─────────────────────────────

module "frontend-launch-template" {
  source         = "../../modules/frontend/launch-template"
  aws_region     = var.aws_region
  instance_type  = var.instance_type
  frontend_sg_id = module.infrastructure.frontend_server_sg_id
  key_name       = var.key_name
  instanceid     = module.frontend.frontend_instance_id
}

# ──────────────────────────────
# Backend Launch Template
# ──────────────────────────────

module "backend-launch-template" {
  source        = "../../modules/backend/launch-template"
  aws_region    = var.aws_region
  instance_type = var.instance_type
  backend_sg_id = module.infrastructure.backend_server_sg_id
  key_name      = var.key_name
  instanceid    = module.backend.backend_instance_id
}

# ────────────────────────────
# Auto Scaling Group frontend
# ─────────────────────────────

module "frontend-asg" {
  source                      = "../../modules/frontend/asg"
  aws_region                  = var.aws_region
  frontend_launch_template_id = module.frontend-launch-template.frontend_launch_template_id
  web_subnet_1_id             = module.infrastructure.private_web_subnets[0]
  web_subnet_2_id             = module.infrastructure.private_web_subnets[1]
  frontend_target_group_arn   = module.frontend-alb.alb_target_group_arn
}

# ────────────────────────────
# Auto Scaling Group backend
# ─────────────────────────────

module "backend-asg" {
  source                     = "../../modules/backend/asg"
  aws_region                 = var.aws_region
  backend_launch_template_id = module.backend-launch-template.backend_launch_template_id
  app_subnet_1_id            = module.infrastructure.private_app_subnets[0]
  app_subnet_2_id            = module.infrastructure.private_app_subnets[1]
  backend_target_group_arn   = module.backend-alb.alb_target_group_arn
}