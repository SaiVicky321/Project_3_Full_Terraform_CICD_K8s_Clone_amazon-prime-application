resource "aws_security_group" "my-SG" {
  name =  "${var.servername}-SG"
  description = "creating SG groups for main server amz prime video SG"

# Enabling SSH Port
  ingress {
    description     = "SSH Port"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Enabling Jenkins Port
  ingress {
    description     = "Jenkins Port"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

# Enabling Sonar-Qube Port
  ingress {
    description     = "Sonar-Qube Port"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

# Enabling HTTP Port
  ingress {
    description     = "HTTP Port"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

# Enabling HTTPS Port
  ingress {
    description     = "HTTPS Port"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    

# Enabling Grafana Port
  ingress {
    description     = "Grafana Port"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

# Enabling Prometheus Port
  ingress {
    description     = "Prometheus Port"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

# Enabling Prometheus metrics Server Port
  ingress {
    description     = "Prometheus metrics Server Port"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Enabling Kubernetes API Server Port
  ingress {
    description     = "Kubernetes API Server Port"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Enabling Kubernetes etcd cluster Port
  ingress {
    description     = "Kubernetes etcd cluster Port"
    from_port       = 2379
    to_port         = 2380
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Enabling Kubernetes Port
  ingress {
    description     = "Kubernetes Port"
    from_port       = 10250
    to_port         = 10260
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Enabling Kubernetes NodePort
  ingress {
    description     = "Kubernetes NodePort"
    from_port       = 30000
    to_port         = 30767
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { 
    description     = "outbound traffic"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}