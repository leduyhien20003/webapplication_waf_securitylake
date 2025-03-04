# EC2 Instance in Public Subnet
resource "aws_instance" "web_instance1" {
  ami           = var.amis[var.region]   
  instance_type = var.instance_type   
  subnet_id     = var.subnet_id1
  security_groups = var.security_groups
  key_name = var.key_name
  associate_public_ip_address = true   
  
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-server
              sudo systemctl start mysql.service
              sudo systemctl enable mysql.service
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello from Instance 1</h1>" | sudo tee /var/www/html/index.html
              sudo apt install -y php php-mysql 
              sudo apt install unzip
              EOF 

  tags = {
    Name = "web_instance1"
  }
}

resource "aws_instance" "web_instance2" {
  ami           = var.amis[var.region]   
  instance_type = var.instance_type   
  subnet_id     = var.subnet_id2
  security_groups = var.security_groups
  key_name = var.key_name
  associate_public_ip_address = true    
  
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-server
              sudo systemctl start mysql.service
              sudo systemctl enable mysql.service
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello from Instance 2</h1>" | sudo tee /var/www/html/index.html
              sudo apt install -y php php-mysql 
              sudo apt install unzip
              EOF 

  tags = {
    Name = "web_instance2"
  }
}
