/*
Cette configuration Terraform permet de mettre en place une application web basique sur AWS à l'aide d'une instance EC2 exécutant Nginx.
Elle comprend les composants réseau nécessaires, tels qu'un VPC, un sous-réseau, une passerelle Internet et des groupes de sécurité.
Des identifiants AWS sont requis pour appliquer cette configuration. Ils peuvent être définis à l'aide de variables d'environnement ou de l'interface CLI AWS.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region
}

##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-vpc") })
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = local.common_tags
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.vpc_subnet_cidr
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(local.common_tags, { Name = lower("${local.naming_prefix}-public-subnet1") })
}

# ROUTING #
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-rtb") })
}

resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = lower("${local.naming_prefix}-nginx_sg")
  vpc_id = aws_vpc.app.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data_replace_on_change = true
  tags                        = merge(local.common_tags, { Name = lower("${local.naming_prefix}-nginx1") })

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
sudo cat > /usr/share/nginx/html/index.html << 'WEBSITE'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ALERTE CRITIQUE</title>
    <link href="https://fonts.googleapis.com/css2?family=Nosifer&family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <style>
        /* RESET & BASE */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            cursor: not-allowed; /* Curseur interdit pour l'effet */
        }

        body {
            background-color: #000;
            color: #ff0000;
            font-family: 'Share Tech Mono', monospace;
            height: 100vh;
            width: 100vw;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-transform: uppercase;
            position: relative;
        }

        /* FOND STROBOSCOPIQUE (Pulse Rouge) */
        body::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(50,0,0,1) 0%, rgba(0,0,0,1) 90%);
            animation: pulseBg 0.2s infinite alternate;
            z-index: -2;
        }

        /* EFFET CRT (Écran vieux téléviseur) */
        .scanlines {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(
                to bottom,
                rgba(255,255,255,0),
                rgba(255,255,255,0) 50%,
                rgba(0,0,0,0.4) 50%,
                rgba(0,0,0,0.4)
            );
            background-size: 100% 4px;
            pointer-events: none;
            z-index: 10;
        }

        /* EFFET VIGNETTE SOMBRE */
        .vignette {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, transparent 40%, black 100%);
            z-index: 11;
            pointer-events: none;
        }

        /* CONTENEUR PRINCIPAL */
        .container {
            border: 5px solid red;
            padding: 3rem;
            background: rgba(0, 0, 0, 0.8);
            box-shadow: 0 0 20px red, inset 0 0 20px red;
            text-align: center;
            animation: shake 2s infinite;
            z-index: 5;
            max-width: 90%;
        }

        /* TITRE EFFRAYANT */
        h1 {
            font-family: 'Nosifer', cursive;
            font-size: 4rem;
            margin-bottom: 20px;
            text-shadow: 4px 4px 0px #330000;
            animation: glitchText 0.3s infinite;
        }

        /* SOUS-TEXTE */
        h2 {
            font-size: 2rem;
            letter-spacing: 5px;
            background-color: #ff0000;
            color: #000;
            padding: 5px;
            margin-bottom: 30px;
            animation: blink 0.1s infinite;
        }

        p {
            font-size: 1.2rem;
            line-height: 1.5;
            color: #ff4444;
        }

        /* SYMBOLES D'ATTENTION */
        .icons {
            font-size: 3rem;
            margin-top: 20px;
            animation: spinWarning 1s infinite steps(2);
        }

        /* ANIMATIONS */
        @keyframes pulseBg {
            0% { opacity: 0.8; }
            100% { opacity: 1; box-shadow: inset 0 0 100px red; }
        }

        @keyframes blink {
            0% { opacity: 1; }
            50% { opacity: 0; }
            100% { opacity: 1; }
        }

        @keyframes shake {
            0% { transform: translate(1px, 1px) rotate(0deg); }
            10% { transform: translate(-1px, -2px) rotate(-1deg); }
            20% { transform: translate(-3px, 0px) rotate(1deg); }
            30% { transform: translate(3px, 2px) rotate(0deg); }
            40% { transform: translate(1px, -1px) rotate(1deg); }
            50% { transform: translate(-1px, 2px) rotate(-1deg); }
            60% { transform: translate(-3px, 1px) rotate(0deg); }
            70% { transform: translate(3px, 1px) rotate(-1deg); }
            80% { transform: translate(-1px, -1px) rotate(1deg); }
            90% { transform: translate(1px, 2px) rotate(0deg); }
            100% { transform: translate(1px, -2px) rotate(-1deg); }
        }

        @keyframes glitchText {
            0% { transform: skew(0deg); }
            20% { transform: skew(-10deg); color: #fff; }
            40% { transform: skew(10deg); }
            60% { transform: skew(-5deg); filter: blur(2px);}
            80% { transform: skew(5deg); }
            100% { transform: skew(0deg); }
        }

        @keyframes spinWarning {
            0% { transform: scale(1); }
            50% { transform: scale(1.2); color: #fff; }
            100% { transform: scale(1); }
        }

        /* BRUIT VISUEL (NOISE) */
        .noise {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            pointer-events: none;
            z-index: 12;
            opacity: 0.1;
            background: url('https://media.giphy.com/media/oEI9uBYSzLpBK/giphy.gif'); 
            background-size: cover;
        }

    </style>
</head>
<body>

    <div class="scanlines"></div>
    <div class="vignette"></div>
    <div class="noise"></div>

    <div class="container">
        <h1>GOONING<br>ALERT</h1>
        <h2>⚠️ DANGER IMMÉDIAT ⚠️</h2>
        
        <p>ERREUR SYSTÈME #0X992<br>
        VOTRE CERVEAU EST COMPROMIS.<br>
        NE FERMEZ PAS CETTE PAGE.</p>

        <div class="icons">
            ☣️ ☠️ ☣️
        </div>
    </div>
</body>
</html>
WEBSITE
EOF

}
