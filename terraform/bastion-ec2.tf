resource "aws_instance" "bastion-host" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.basic_sg.id]
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/user_data/nginx.sh", {
    endpoint = "https://${aws_opensearch_domain.main.endpoint}"
    domain   = var.os_domain
    email    = var.email
  })

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_security_group" "basic_sg" {
  name        = "basic-sg"
  description = "Allow SSH, HTTP/HTTPS from my anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip]
  }

  tags = {
    Name = "basic-sg"
  }
}

resource "aws_eip" "bastion-host-public-ip" {
  domain = "vpc"

  tags = {
    Name = "bastion-host-ip"
  }
}

resource "aws_eip_association" "bastion-host-eip-association" {
  instance_id   = aws_instance.bastion-host.id
  allocation_id = aws_eip.bastion-host-public-ip.id
}

resource "aws_route53_record" "bastion_host" {
  zone_id = var.route53_zone_id
  name    = var.os_domain
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion-host-public-ip.public_ip]
}
