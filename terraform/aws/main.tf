terraform {
    required_version = ">= 0.9.11"
}

provider "aws" { # This is the AWS account in which everything will be installed.
  region = "${var.AWS_DEFAULT_REGION}"
  profile = "${var.installation_name}"
}

provider "aws" { # This is a separate AWS account where we keep our route53 config. Please feel free to adapt accordingly.
  region = "${var.AWS_DEFAULT_REGION}"
  profile = "default"
  alias = "route53_account"
}

module "aws-k8s" {
  source = "modules/k8s"

  aws_avail_zones = "${var.aws_avail_zones}"
  aws_cluster_name="${var.aws_cluster_name}"
  aws_cluster_ubuntu_16_04_ami = "${var.aws_cluster_ubuntu_16_04_ami}"
  aws_bastion_debian_jessie_ami = "${var.aws_bastion_debian_jessie_ami}"
  aws_bastion_size = "${var.aws_bastion_size}"
  AWS_DEFAULT_REGION = "${var.AWS_DEFAULT_REGION}"
  aws_elb_api_port = "${var.aws_elb_api_port}"
  aws_etcd_num = "${var.aws_etcd_num}"
  aws_etcd_size = "${var.aws_etcd_size}"
  aws_kube_master_num = "${var.aws_kube_master_num}"
  aws_kube_master_size = "${var.aws_kube_worker_size}"
  aws_kube_worker_num = "${var.aws_kube_worker_num}"
  aws_kube_worker_size = "${var.aws_kube_worker_size}"
  aws_public_subnet_ids = "${var.aws_public_subnet_ids}"
  aws_route53_zone_id = "${var.aws_route53_zone_id}"
  AWS_SSH_KEY_NAME = "${var.AWS_SSH_KEY_NAME}"
  installation_name = "${var.installation_name}"
  k8s_secure_api_port = "${var.k8s_secure_api_port}"
  kube_insecure_apiserver_address = "${var.kube_insecure_apiserver_address}"
  service_loadbalancer_http_port = "${var.service_loadbalancer_http_port}"
  service_loadbalancer_https_port = "${var.service_loadbalancer_https_port}"
  vpc_id = "${var.vpc_id}"
}
