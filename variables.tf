variable "aws_region" {
    description = "La région AWS dasn laquelle déployer les ressources"
    type = string
    default = "us-east-1"
}

variable "vpc_cidr_bloc" {
    description = "Bloc CIDR VPC"
    type = string
    default =  ""

}

variable ""{}