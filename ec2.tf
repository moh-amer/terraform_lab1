
# resource "tls_private_key" "rsa_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  # Name of key : Write the custom name of your key
  key_name = "aws_keys_pairs"

  # Public Key: The public will be generated using the reference of tls_private_key.terrafrom_generated_private_key
  public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh

  # Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > aws_keys_pairs.pem
      chmod 400 aws_keys_pairs.pem
    EOT
  }
}


locals {
  private_key_base64 = base64encode(tls_private_key.terrafrom_generated_private_key.private_key_pem)
}

resource "aws_instance" "bastion_ec2" {
  ami                         = "ami-06e46074ae430fba6"
  instance_type               = "t2.nano"
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet01.id
  tags = {
    Name = "Bastion Instance"
  }

  key_name = "aws_keys_pairs"

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"

    # Mention the exact private key name which will be generated 
    private_key = file("aws_keys_pairs.pem")
    timeout     = "4m"
  }

  user_data = <<-EOF
              #!/bin/bash
                echo '${local.private_key_base64}' | base64 -d > /home/ec2-user/key.pem
              EOF


  #   user_data = <<-EOF
  # #! /bin/bash
  # "echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > ~/aws_keys_pairs.pem "
  # "chmod 400 ~/aws_keys_pairs.pem"
  #       EOF


  #   user_data = <<EOF
  #   #! /bin/bash
  #   "sudo echo '${tls_private_key.rsa_key.private_key_pem} > ~/pkey.pem' "
  #   "sudo mkdir -p /home/ec2-user/.ssh"
  #   "sudo touch /home/ec2-user/.ssh/authorized_keys"
  #   "sudo echo '${tls_private_key.rsa_key.public_key_openssh}' > ~/.ssh/authorized_keys"
  #   "sudo chown -R ec2-user:ec2-user /home/ec2-user/.ssh"
  #   "sudo chmod 700 ~/.ssh"
  #   "sudo chmod 600 ~/.ssh/authorized_keys"
  #   "sudo usermod -aG sudo ec2-user"
  #     EOF
}


resource "aws_instance" "app_instance" {
  ami             = "ami-06e46074ae430fba6"
  instance_type   = "t2.nano"
  security_groups = [aws_security_group.allow_ssh_port_3000_cidr.id]
  subnet_id       = aws_subnet.private_subnet01.id
  key_name        = "aws_keys_pairs"


  tags = {
    Name = "Application Instance"
  }


  #   user_data = <<EOF
  #     #! /bin/bash
  #   "sudo mkdir -p /home/ec2-user/.ssh"
  #   "sudo touch /home/ec2-user/.ssh/authorized_keys"
  #   "sudo echo '${tls_private_key.rsa_key.public_key_openssh}' > /home/ec2-user/.ssh/authorized_keys"
  #   "sudo chown -R ec2-user:ec2-user /home/ec2-user/.ssh"
  #   "sudo chmod 700 /home/ec2-user/.ssh"
  #   "sudo chmod 600 /home/ec2-user/.ssh/authorized_keys"
  #   "sudo usermod -aG sudo ec2-user"
  #     EOF

}

# resource "local_file" "private_key" {
#   content  = tls_private_key.rsa_key.private_key_pem
#   filename = "${path.module}/pkey.pem"
# }

# resource "local_file" "public_key" {
#   content  = tls_private_key.rsa_key.public_key_openssh
#   filename = "${path.module}/key.pub"
# }
