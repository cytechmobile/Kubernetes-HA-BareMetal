variable "vpc_id" {
    description = "CIDR Blocks for AWS VPC"
}

variable "aws_cluster_name" {
    description = "Name of Cluster"
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
