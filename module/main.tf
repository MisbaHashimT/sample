# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_ipv4_cidr

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "my_pub_st" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

# Public Subnet 2
resource "aws_subnet" "my_pub_st_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_2
  tags = {
    Name = "${var.environment}-public-subnet-2"
  }
}

# Private Subnet
resource "aws_subnet" "my_pvt_st" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.environment}-public-routetable"
  }
}

# Public Route Table Subnet Association
resource "aws_route_table_association" "pub_rt_assc_1" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.my_pub_st.id
}

resource "aws_route_table_association" "pub_rt_assc_2" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.my_pub_st_2.id
}

# Create Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_ngw.id
  }

  tags = {
    Name = "${var.environment}-private-routetable"
  }
}

# Private Route Table Subnet Association
resource "aws_route_table_association" "pvt_rt_assc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.my_pvt_st.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "my_ngw" {
  subnet_id     = aws_subnet.my_pub_st.id
  allocation_id = aws_eip.eip.id
  depends_on    = [aws_internet_gateway.my_igw]
}

# Security Group for EC2 Instance
resource "aws_security_group" "my-sg" {
  name        = "main-sg"
  description = "Security group for web server instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    security_groups = [aws_security_group.my-sg-lb.id]
    from_port       = 0
    to_port         = 0
    protocol        = -1 # all traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }

  tags = {
    Name = "${var.environment}-sg"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "my-sg-lb" {
  name        = "lb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.my_vpc.id

  #   dynamic "ingress" {
  #   for_each = var.lb_ingress_rules
  #   content {
  #     from_port   = [ingress.value.from_port]
  #     to_port     = [ingress.value.to_port]
  #     protocol    = [ingress.value.protocol]
  #     cidr_blocks = [ingress.value.cidr_blocks]
  #   }
  # }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = -1
  }

  tags = {
    Name = "${var.environment}-sg-lb"
  }
}

# Launch Template
resource "aws_launch_template" "linux-ami" {
  name_prefix   = "web-server"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.my-sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.root_volume_size
      volume_type = var.volume_type_ebs
    }
  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = var.additional_volume_size
      volume_type = var.volume_type_ebs
    }
  }

  monitoring {
    enabled = true
  }

  user_data = filebase64("./module/script.sh")
}

# Target Group
resource "aws_lb_target_group" "my-tg-lb" {
  name     = "app-tg-new"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.environment}-lb-target-group"
  }
}

# Application Load Balancer
resource "aws_lb" "my-alb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my-sg-lb.id]
  subnets            = [aws_subnet.my_pub_st.id, aws_subnet.my_pub_st_2.id]

  tags = {
    Name = "${var.environment}-lb"
  }
}

# Listener for Application Load Balancer
resource "aws_lb_listener" "my-listener" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my-tg-lb.arn
    type             = "forward"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "my-asg" {
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  vpc_zone_identifier  = [aws_subnet.my_pvt_st.id]
  health_check_type    = "ELB"
  target_group_arns    = [aws_lb_target_group.my-tg-lb.arn]

  launch_template {
    id      = aws_launch_template.linux-ami.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "alb_name" {
  value = aws_lb.my-alb.dns_name
}

output "availability_zone_debug" {
  value = var.availability_zone

}