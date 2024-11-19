#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html><h1>Welcome to My Website!</h1><p>Hosted on Amazon EC2 with Apache</p></html>" >/var/www/html/index.html