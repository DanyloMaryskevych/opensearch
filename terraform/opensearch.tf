data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "bastion_cert" {
  domain      = "opensearch.lionworks.net"
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_opensearch_domain" "main" {
  domain_name = var.domain_name

  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 2

    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
    volume_type = "gp3"
  }

  vpc_options {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  access_policies = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "es:ESHttp*",
        Resource  = "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
      }
    ]
  })

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"

    custom_endpoint_enabled = true

    custom_endpoint                 = var.os_domain
    custom_endpoint_certificate_arn = data.aws_acm_certificate.bastion_cert.arn
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = false

    master_user_options {
      master_user_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/opensearch-admin-role"
    }
  }

  tags = {
    Name = "SecureOpenSearch"
  }
}

#resource "aws_opensearch_domain_saml_options" "os-saml" {
#  domain_name = aws_opensearch_domain.main.domain_name
#
#  saml_options {
#    enabled             = true
#    master_backend_role = "super_user_role"
#    roles_key           = "Role"
#
#    idp {
#      entity_id        = ""
#      metadata_content = file("${path.module}/saml/metadata.xml")
#    }
#  }
#}

resource "aws_security_group" "opensearch_sg" {
  name        = "opensearch-sg"
  description = "Allow traffic from bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.basic_sg.id]
    description     = "Allow HTTPS from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip]
  }

  tags = {
    Name = "opensearch-sg"
  }
}
