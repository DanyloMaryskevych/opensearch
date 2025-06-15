resource "aws_instance" "keycloak" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.basic_sg.id]
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/user_data/keycloak.sh", {
    endpoint = "http://localhost:8080"
    domain   = var.auth_domain
    email    = var.email
  })

  tags = {
    Name = "keycloak-server"
  }
}

resource "aws_eip" "keycloak-public-ip" {
  domain = "vpc"

  tags = {
    Name = "keycloak-ip"
  }
}

resource "aws_eip_association" "keycloak-eip-association" {
  instance_id   = aws_instance.keycloak.id
  allocation_id = aws_eip.keycloak-public-ip.id
}

resource "aws_route53_record" "keycloak" {
  zone_id = var.route53_zone_id
  name    = var.auth_domain
  type    = "A"
  ttl     = 300
  records = [aws_eip.keycloak-public-ip.public_ip]
}

