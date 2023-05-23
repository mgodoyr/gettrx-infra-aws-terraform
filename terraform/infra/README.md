GETTRX infrastructure terraform

Virtual Private Cloud (VPC): Here, a VPC named "gettrx_vpc" is being created with DNS support enabled. A VPC is a dedicated virtual network within AWS that provides resource isolation.

Subnets: Two public and two private subnets are being created within the VPC. Each subnet is placed in a different availability zone for redundancy and high availability. The public subnet has the ability to assign a public IP to instances at launch.

Internet Gateway (IGW): An Internet Gateway is created and attached to the VPC. The IGW allows communication between instances in the VPC and the internet.

NAT Gateways and EIPs: Two NAT Gateways are created, one for each public subnet, which allows instances in the private subnets to access the internet without having a public IP.

Route Tables: Two route tables are created, one for the public subnets and one for the private subnets. The public route table has a route to the IGW, allowing instances in the public subnets to access the internet directly.

Security Group: A security group for a load balancer is created. This security group has ingress rules for HTTP, HTTPS, a specific TCP port (3000), and SSH. There's also an egress rule to allow all outgoing traffic.

Application Load Balancer (ALB): An ALB is created with two listeners for port 80 (HTTP) and port 443 (HTTPS). The HTTP listener is set to redirect to HTTPS.

EC2 instance: An EC2 instance is launched, which uses a specified Ubuntu Server AMI and a user data script to install Ansible and AWS CLI, then download and run an Ansible playbook from an S3 bucket.

RDS instance: An RDS PostgreSQL database instance is created within the private subnet group. Its traffic is regulated by a dedicated security group. It has a parameter and an option group for specific PostgreSQL configurations, is encrypted with a KMS key, and has performance insights enabled.