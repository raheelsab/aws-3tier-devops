data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
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