resource "aws_instance" "app" {
  ami           = "ami-08d4f68a071dd2d26"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.app.id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  iam_instance_profile = aws_iam_instance_profile.app.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker amazon-ssm-agent

              systemctl enable docker
              systemctl start docker

              systemctl enable amazon-ssm-agent
              systemctl restart amazon-ssm-agent

              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "app-server"
    Tier = "application"
  }
}