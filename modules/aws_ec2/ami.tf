#------------------------------------------------------------------------------
#  Copyright (c) 2022 Infiot Inc.
#  All rights reserved.
#------------------------------------------------------------------------------

# Preferred lookup: AWS Marketplace publishes an SSM parameter alias per release
# (e.g. /aws/service/marketplace/prod-jenciju7u4bvk/r6.3.371) that resolves directly
# to the correct AMI ID for the current region, avoiding fragile name-prefix matching.
data "aws_ssm_parameter" "netskope_gw_ssm_ami" {
  count = var.aws_instance.ami_ssm_parameter != "" ? 1 : 0
  name  = var.aws_instance.ami_ssm_parameter
}

# Fallback lookup used only when ami_ssm_parameter is left empty.
data "aws_ami" "netskope_gw_image_id" {
  count       = var.aws_instance.ami_ssm_parameter == "" ? 1 : 0
  most_recent = true
  owners      = [var.aws_instance.ami_owner]

  filter {
    name   = "name"
    values = [join("", [var.aws_instance.ami_name, "*"])]
  }
}

locals {
  netskope_gw_image_id = var.aws_instance.ami_ssm_parameter != "" ? data.aws_ssm_parameter.netskope_gw_ssm_ami[0].value : data.aws_ami.netskope_gw_image_id[0].image_id
}
