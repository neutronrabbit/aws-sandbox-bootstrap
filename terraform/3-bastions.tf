variable "allowed_ip" {
  description = "90.201.38.126 for SSH access (CIDR format)"
  default     = "90.201.38.126/32" # Replace with your actual IP or pass via tfvars
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.main.id

/*
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }
*/
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}

data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] 
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# EC2 Bastions
resource "aws_instance" "bastions" {
  for_each = toset(var.availability_zones)

  ami                         = data.aws_ami.latest_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.dmz[each.key].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.name

  # Install kubectl + aws-cli
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y awscli jq
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/
              mkdir -p /home/ec2-user/.kube
              chown -R ec2-user:ec2-user /home/ec2-user/.kube
              EOF

  tags = {
    Name = "bastion-${each.key}"
  }
}


