variable "aws_vpc_cidr_block" {
    description = "CIDR Blocks for AWS VPC"
}


variable "aws_cluster_name" {
    description = "Name of Cluster"
}


variable "aws_avail_zones" {
    description = "AWS Availability Zones Used"
    type = "list"
}

variable "aws_cidr_subnets_public" {
  description = "CIDR Blocks for public subnets in Availability zones"
  type    = "list"
}

variable "aws_elb_api_port" {
    description = "Port for AWS ELB"
}

variable "k8s_secure_api_port" {
    description = "Secure Port of K8S API Server"
}

variable "service_loadbalancer_http_port" {
    description = "HTTP Port for Kubernetes Service LoadBalancer"
}
variable "service_loadbalancer_https_port" {
    description = "HTTPS Port for Kubernetes Service LoadBalancer"
}
