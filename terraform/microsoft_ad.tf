resource "aws_directory_service_directory" "managed_ad" {
  name     = "corp.dan.com"
  password = "SuperSecurePassw0rd!"
  size     = "Small"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.private_subnet_ids
  }

  tags = {
    Name = "ManagedMicrosoftAD"
    Env  = "Dev"
  }

  #  lifecycle {
  #    prevent_destroy = true
  #    ignore_changes  = [
  #      size,
  #      vpc_settings,
  #      password,
  #      tags,
  #    ]
  #  }
}