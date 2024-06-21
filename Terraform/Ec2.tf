resource "aws_security_group" "sgforstrapi" {
  vpc_id      = aws_vpc.vpcstrapi.id
  description = "This is for strapy application"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sg-strapi"
  }

}

resource "aws_instance" "ec2forstrapi" {
  ami                         = "ami-03c983f9003cb9cd1"
  availability_zone = "us-west-2a"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.sgforstrapi.id]
  subnet_id                   = aws_subnet.publicsubnet.id
  key_name                    = "taskspt"
  associate_public_ip_address = true
  tags = {
    Name = "ec2forstrapi"
  }
}

resource "null_resource" "example" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa") 
      host        = aws_instance.ec2forstrapi.public_ip
    }

    provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g pm2",
      "cd /srv",
      "git clone https://github.com/maheshryali/pearthoughpracticerepo.git",
      "git checkout mahesh-branch",
      "sudo chown -R ubuntu:ubuntu /srv/strapi",
      "sudo chmod -R 755 /srv/strapi",
      "npm install",
      "pm2 start npm --name strapi -- run develop",
      "pm2 save"
    ]

  depends_on = [
    aws_instance.ec2forstrapi
  ]
}
  }

}