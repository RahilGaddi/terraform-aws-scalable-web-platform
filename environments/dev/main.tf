# ─────────────────────────────
# INFRA 
# ──────────────────────────────
module "infrastructure"{
    source = "../..modules/infrastructure"
    aws_region = var.aws_region
    vpc_cidr = var.vpc_cidr
    vpc_name = var.vpc_name
    public_subnet_cidr_1 = var.public_subnet_1_cidr
    public_subnet_cidr_2 = var.public_subnet_2_cidr 
    private_subnet_cidr_1 = var.private_subnet_1_cidr
    private_subnet_cidr_2 = var.private_subnet_2_cidr
    private_subnet_cidr_3 = var.private_subnet_3_cidr
    private_subnet_cidr_4 = var.private_subnet_4_cidr
    private_subnet_cidr_5 = var.private_subnet_5_cidr
    private_subnet_cidr_6 = var.private_subnet_6_cidr
    availability_zone_1a = var.availability_zone_2a
    availability_zone_1b = var.availability_zone_2b
    vpc_id = module.infrastructure.vpc_id
    allowed_ssh_cidr = var.allowed_ssh_cidr
}

# ────────────────────────────
# frontend ec2 instance 
# ─────────────────────────────

module "frontend-ec2"{
    source = "../..modules/frontend/ec2"
    aws_region = var.aws_regionn
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = module.infrastructure.private_subnet_1_id   
    security_group_id = module.infrastructure.aws_security_group.frontend_server.id
}

# ────────────────────────────
# backend ec2 instance public
# ─────────────────────────────

module "backend_ec2"{
    source = "../..modules/backend/ec2"
    aws_region = var.aws_regionn
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = module.infrastructure.private_subnet_3_id
    security_group_id = module.infrastructure.aws_security_group.backend_server.id
}

# ────────────────────────────
# AWS Bastion Host
# ─────────────────────────────

module "bastion" {
    source = "../..modules/bastion"
    aws_region = var.aws_regionn
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = module.infrastructure.public_subnet_1_id
    security_group_id = module.infrastructure.aws_security_group.bastion_host.id
}

# ─────────────────────────────
# RDS (DB Tier)
# ─────────────────────────────

module "database"{
    source = "../..modules/database"
    aws_region = var.aws_regionn
    identifier = var.identifier
    db_name = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_subnet_1_id = module.infrastructure.private_subnet_5_id
    db_subnet_2_id = module.infrastructure.private_subnet_6_id
    rds_sg_id = module.infrastructure.aws_security_group.database.id
}

