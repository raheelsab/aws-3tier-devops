resource "aws_iam_role" "app" {
  name = "aws-3tier-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "aws-3tier-app-role"
  }
}

resource "aws_iam_instance_profile" "app" {
  name = "aws-3tier-app-profile"
  role = aws_iam_role.app.name
}
resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}