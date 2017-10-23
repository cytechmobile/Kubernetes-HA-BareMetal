data "aws_vpc" "cluster-vpc" {
  id = "${var.vpc_id}"
}

#Kubernetes Security Groups

resource "aws_security_group" "kubernetes" {
  name = "kubernetes-${var.aws_cluster_name}-securitygroup"
  vpc_id = "${data.aws_vpc.cluster-vpc.id}"

  tags {
    Name = "kubernetes-${var.aws_cluster_name}-securitygroup"
  }
}
resource "aws_security_group_rule" "allow-all-ingress" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks= ["${data.aws_vpc.cluster-vpc.cidr_block}"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}
resource "aws_security_group_rule" "allow-all-egress" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group" "k8s-bastion" {
  name = "k8s-bastion-${var.aws_cluster_name}-securitygroup"
  vpc_id = "${data.aws_vpc.cluster-vpc.id}"

  tags {
    Name = "k8s-bastion-${var.aws_cluster_name}-securitygroup"
  }
}
resource "aws_security_group_rule" "allow-ssh-connections" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.k8s-bastion.id}"
}

resource "aws_security_group" "k8s-loadbalancer" {
    name = "k8s-loadbalancer-${var.aws_cluster_name}-securitygroup"
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "k8s-loadbalancer-${var.aws_cluster_name}-securitygroup"
    }
}
resource "aws_security_group_rule" "allow-http-connections" {
    type = "ingress"
    from_port = "${var.service_loadbalancer_http_port}"
    to_port = "${var.service_loadbalancer_http_port}"
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.k8s-loadbalancer.id}"
}
resource "aws_security_group_rule" "allow-https-connections" {
    type = "ingress"
    from_port = "${var.service_loadbalancer_https_port}"
    to_port = "${var.service_loadbalancer_https_port}"
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.k8s-loadbalancer.id}"
}

resource "aws_security_group" "aws-kubernetes-api" {
  name = "kubernetes-${var.aws_cluster_name}-securitygroup-elb"
  vpc_id = "${data.aws_vpc.cluster-vpc.id}"

  tags {
    Name = "kubernetes-${var.aws_cluster_name}-securitygroup-elb"
  }
}
resource "aws_security_group_rule" "aws-allow-api-access" {
  type = "ingress"
  from_port = "${var.aws_elb_api_port}"
  to_port = "${var.k8s_secure_api_port}"
  protocol = "TCP"
  cidr_blocks = [
    "192.168.253.0/24"
  ]
  security_group_id = "${aws_security_group.aws-kubernetes-api.id}"
}
resource "aws_security_group_rule" "aws-allow-api-egress" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.aws-kubernetes-api.id}"
}