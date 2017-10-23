variable "AWS_SSH_KEY_NAME" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "AWS_DEFAULT_REGION" {
  description = "AWS Region"
}

//General Cluster Settings

variable "aws_cluster_name" {
  description = "Name of AWS Cluster"
}
variable "installation_name" {
  description = "Name of your installation. This is so you can set up more than one installations using the same source"
}
variable "k8s_domain_name" {
  default = "The DNS domain name under which you will be creating your FQDNs."
}


//AWS VPC Variables

variable "vpc_id" {
  description = "The id of the VPC"
}

variable "aws_avail_zones" {
  description = "Availability Zones Used"
  type = "list"
}

variable "aws_public_subnet_ids" {
  description = "CIDR Blocks for public subnets in Availability Zones"
  type = "list"
}

//AWS EC2 Settings

variable "aws_bastion_debian_jessie_ami" {
  description = "AMI ID for Bastion Host in chosen AWS Region"
}

variable "aws_bastion_size" {
  description = "EC2 Instance Size of Bastion Host"
}

/*
* AWS EC2 Settings
* The number should be divisable by the number of used
* AWS Availability Zones without an remainder.
*/
variable "aws_kube_master_num" {
  description = "Number of Kubernetes Master Nodes"
}

variable "aws_kube_master_size" {
  description = "Instance size of Kube Master Nodes"
}

variable "aws_etcd_num" {
  description = "Number of etcd Nodes"
}

variable "aws_etcd_size" {
  description = "Instance size of etcd Nodes"
}

variable "aws_kube_worker_num" {
  description = "Number of Kubernetes Worker Nodes"
}

variable "aws_kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes"
}

variable "aws_cluster_ubuntu_16_04_ami" {
  description = "AMI ID for Kubernetes Cluster"
}
/*
* AWS ELB Settings
*
*/
variable "aws_elb_api_port" {
  description = "Port for AWS ELB"
}

variable "k8s_secure_api_port" {
  description = "Secure Port of K8S API Server"
}

variable "kube_insecure_apiserver_address" {
  description= "Bind Address for insecure Port of K8s API Server"
}
variable "service_loadbalancer_http_port" {
  description = "HTTP Port for Kubernetes Service LoadBalancer"
}
variable "service_loadbalancer_https_port" {
  description = "HTTPS Port for Kubernetes Service LoadBalancer"
}


variable "aws_route53_zone_id" {
  description = "Zone ID of Route 53 zone where you will create the FQDNs."
}





// Using already existing VPC to install your cluster in.
module "aws-vpc" {
  source = "../external_vpc"

  vpc_id = "${var.vpc_id}"

  aws_cluster_name = "${var.aws_cluster_name}"

  aws_elb_api_port = "${var.aws_elb_api_port}"
  k8s_secure_api_port = "${var.k8s_secure_api_port}"

  service_loadbalancer_http_port = "${var.service_loadbalancer_http_port}"
  service_loadbalancer_https_port = "${var.service_loadbalancer_https_port}"

}

/* Use this to create your installation in a new VPC.

module "aws-vpc" {
  source = "../vpc"

  aws_cluster_name = "${var.aws_cluster_name}"
  aws_vpc_cidr_block = "${var.aws_vpc_cidr_block}"
  aws_avail_zones="${var.aws_avail_zones}"

  aws_cidr_subnets_public="${var.aws_cidr_subnets_public}"

  aws_elb_api_port = "${var.aws_elb_api_port}"
  k8s_secure_api_port = "${var.k8s_secure_api_port}"

  service_loadbalancer_http_port = "${var.service_loadbalancer_http_port}"
  service_loadbalancer_https_port = "${var.service_loadbalancer_https_port}"

}
*/


module "aws-iam" {
  source = "../iam"

  aws_cluster_name="${var.aws_cluster_name}"
}
