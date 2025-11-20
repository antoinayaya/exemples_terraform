//Démo
variable "aws_region" {
  description = "La région AWS dans laquelle déployer les ressources"
  type        = string
  default     = "us-east-1"
}

//Exercice
variable "vpc_cidr_block" {
  description = "Le bloc CIDR pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  description = "Activer les noms d'hôte DNS dans le VPC"
  type        = bool
  default     = true
}

variable "vpc_subnet_cidr" {
  description = "Le bloc CIDR pour le sous-réseau public"
  type        = string
  default     = "10.0.0.0/24"
}

variable "map_public_ip_on_launch" {
  description = "Mapper les adresses IP publiques lors du lancement du sous-réseau "
  type        = bool
  default     = true
}

variable "http_port" {
  description = "Le port HTTP pour l'application"
  type        = number
}

variable "ec2_instance_type" {
  description = "Le type d'instance EC2 à lancer"
  type        = string
}