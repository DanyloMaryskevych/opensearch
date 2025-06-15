# 🔐 Secure OpenSearch with SSO via Keycloak and AWS Managed AD

This project provisions a secure, production-like **OpenSearch** cluster in AWS using:
- 🔒 **Amazon OpenSearch Service** (in private subnets)
- 🧩 **Keycloak** for SAML-based SSO
- 🏢 **AWS Managed Microsoft AD** as the identity source

Authentication is fully delegated to Keycloak via **SAML**, which integrates with AWS AD as an external user store. HTTPS access is enabled using **Let's Encrypt certificates** and traffic is routed via an Nginx reverse proxy on an EC2 instance.

---

## 🌍 Terraform Variables

| Name                 | Description                                  | Example (Default)                      |
|----------------------|----------------------------------------------|----------------------------------------|
| `region`             | AWS region for all resources                 | `eu-central-1`                         |
| `vpc_id`             | ID of the existing VPC                       | `vpc-0a8c5f...`                        |
| `private_subnet_ids` | List of private subnets for internal services| `["subnet-0389...", "subnet-0f6c..."]` |
| `public_subnet_id`   | Public subnet for internet-facing services   | `subnet-062962...`                     |
| `ami_id`             | AMI ID for EC2 instances                     | `ami-092...`                           |
| `route53_zone_id`    | Route53 hosted zone ID                       | `Z016872...`                           |
| `key_name`           | SSH key pair name                            | `my_key`                               |
| `domain_name`        | Base domain name for resources               | `secure-opensearch`                    |
| `os_domain`          | Public DNS name for OpenSearch               | `opensearch.domain.com`                |
| `auth_domain`        | Public DNS name for Keycloak                 | `auth.domain.com`                      |
| `email`              | Email address for Let's Encrypt certs        | `my.mail@gmail.com`                    |

## 🚀 Getting Started

Make sure you have [Terraform](https://developer.hashicorp.com/terraform/install) installed.

```bash
terraform init
terraform plan
terraform apply
```