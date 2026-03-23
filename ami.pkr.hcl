packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.8.0"
    }
  }
}

# -----------------------
# Variables
# -----------------------

variable "region"           { type = string }
variable "base_ami"         { type = string }
variable "instance_type"    { type = string }
variable "vpc_id"           { type = string }
variable "subnet_id"        { type = string }
variable "instance_profile" { type = string }
variable "app_name"         { type = string }
variable "environment"      { type = string }

variable "kms_key_id" {
  type    = string
  default = null
}

variable "root_volume_size" {
  type    = number
  default = 20
}

# -----------------------
# Source (YOU MISSED THIS)
# -----------------------

source "amazon-ebs" "secure_app" {

  region        = var.region
  source_ami    = var.base_ami
  instance_type = var.instance_type
  ssh_username  = "ec2-user"

  communicator  = "ssh"
  ssh_interface = "session_manager"

  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false

  iam_instance_profile = var.instance_profile

  ami_name        = "${var.app_name}-${var.environment}-{{timestamp}}"
  ami_description = "Node.js ${var.app_name} AMI - {{timestamp}}"

  ena_support = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.kms_key_id
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}"
    Application = var.app_name
    Environment = var.environment
    BuiltBy     = "packer"
  }

  run_tags = {
    Name = "${var.app_name}-packer-build"
  }
}

# -----------------------
# Build
# -----------------------

build {

  sources = ["source.amazon-ebs.secure_app"]

  provisioner "file" {
    source      = "."
    destination = "/home/ec2-user/urlshortener"
  }

  provisioner "shell" {
    inline = [
      "set -ex",

      "sudo yum update -y",

      "echo 'Installing Node.js'",
      "curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -",
      "sudo yum install -y nodejs",

      "echo 'Installing PM2'",
      "sudo npm install -g pm2",

      "sudo chown -R ec2-user:ec2-user /home/ec2-user/urlshortener",

      "cd /home/ec2-user/urlshortener",

      "echo 'Installing dependencies'",
      "npm install",

      "echo 'Starting app'",
      "pm2 start app.js",
      "pm2 save",

      "echo 'Enable PM2 on boot'",
      "pm2 startup systemd -u ec2-user --hp /home/ec2-user",

      "sleep 10",

      "curl -f http://localhost:3000"
    ]
  }

  post-processor "manifest" {
    output = "packer-manifest.json"
  }
}
