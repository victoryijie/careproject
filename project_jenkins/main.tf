provider "aws" {
  region = "eu-west-2"
}



# Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = "ami-0685f8dd865c8e389"
  instance_type = "c7i-flex.large"
  key_name = "ansible"


  security_groups = [aws_security_group.jenkins_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              sudo yum install git -y

              # Install Docker
              sudo yum install docker -y
              systemctl enable docker
              systemctl start docker
              sudo usermod -a -G docker ec2-user
              chkconfig docker on

              # Install Java
              yum install java-21-amazon-corretto -y

              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo \
                https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

              yum install jenkins -y
              systemctl enable jenkins
              systemctl start jenkins
              # sudo usermod -aG docker jenkins
              EOF

  tags = {
    Name = "jenkins-server"
  }
}