module "network" {
  source = "./modules/network"

  vpc_cidr_block              = var.vpc_cidr_block
  public_subnets_cidr_blocks  = var.public_subnets_cidr_blocks
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  availability_zones          = var.availability_zones

}

resource "aws_ecr_repository" "journal-api" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
}

module "eks" {
  source = "./modules/eks"

  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  eks_cluster_name        = var.eks_cluster_name
  github_actions_role_arn = var.github_actions_role_arn
  kubernetes_version      = var.kubernetes_version
  eks_node_group_name     = var.eks_node_group_name
  eks_node_instance_type  = var.eks_node_instance_type
  eks_node_desired_nodes  = var.eks_node_desired_nodes
  eks_node_min_nodes      = var.eks_node_min_nodes
  eks_node_max_nodes      = var.eks_node_max_nodes
}

module "database" {
  source = "./modules/database"

  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  db_identifier        = var.db_identifier
  db_name              = var.db_name
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_username          = var.db_username
  db_password          = var.db_password
}

resource "kubernetes_secret_v1" "journal_api_db_secret" {
  metadata {
    name = "journal-api-db-secret"
  }

  type = "Opaque"

  data = {
    DATABASE_HOST     = split(":", module.database.db_endpoint)[0]
    DATABASE_PORT     = "5432"
    DATABASE_NAME     = var.db_name
    DATABASE_USER     = var.db_username
    DATABASE_PASSWORD = var.db_password
  }
}

resource "kubernetes_secret_v1" "journal_api_secrets" {
  metadata {
    name = "journal-api-secrets"
  }

  type = "Opaque"

  data = {
    DATABASE_URL   = module.database.db_connection_string
    OPENAI_API_KEY = var.openai_api_key
  }
}

resource "kubernetes_config_map_v1" "database_setup_sql" {
  metadata {
    name = "database-setup-sql"
  }

  data = {
    "database_setup.sql" = file("${path.module}/../database_setup.sql")
  }
}

