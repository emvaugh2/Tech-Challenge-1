

# Configures the CloudWatch resource

resource "aws_cloudwatch_log_group" "cw_lg_front" {
  name              = "cloudwatch-loggroup-frontend"
  retention_in_days = 7

  tags = {
    Project = "Tech-Challenge-1"
  }
}


resource "aws_cloudwatch_log_group" "cw_lg_back" {
  name              = "cloudwatch-loggroup-backend"
  retention_in_days = 7

  tags = {
    Project = "Tech-Challenge-1"
  }
}
