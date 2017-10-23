/*
* Create Bastion Instances in AWS
*
*/

resource "aws_eip" "bastion-eip" {
  count = "${length(var.aws_public_subnet_ids)}"
  instance = "${element(aws_instance.bastion-server.*.id,count.index)}"
}
resource "aws_instance" "bastion-server" {
    ami = "${var.aws_bastion_debian_jessie_ami}"
    instance_type = "${var.aws_bastion_size}"
    count = "${length(var.aws_public_subnet_ids)}"
    associate_public_ip_address = true
    availability_zone  = "${element(var.aws_avail_zones,count.index)}"
    subnet_id = "${element(var.aws_public_subnet_ids,count.index)}"


    vpc_security_group_ids = [ "${module.aws-vpc.aws_security_group}", "${module.aws-vpc.aws_security_group_k8s_bastion}" ]

    key_name = "${var.AWS_SSH_KEY_NAME}"

    tags {
        Name = "kubernetes-${var.aws_cluster_name}-bastion-${count.index}"
        Cluster = "${var.aws_cluster_name}"
        Role = "bastion-${var.aws_cluster_name}-${count.index}"
    }
}


/*
* Create K8s Master and worker nodes and etcd instances
*
*/

resource "aws_instance" "k8s-master" {
    ami = "${var.aws_cluster_ubuntu_16_04_ami}"
    instance_type = "${var.aws_kube_master_size}"

    count = "${var.aws_kube_master_num}"


    availability_zone  = "${element(var.aws_avail_zones,count.index)}"
    subnet_id = "${element(var.aws_public_subnet_ids,count.index)}"
    associate_public_ip_address = true


    vpc_security_group_ids = [ "${module.aws-vpc.aws_security_group}", "${module.aws-vpc.aws_security_group_kubernetes_api}" ]


    iam_instance_profile = "${module.aws-iam.kube-master-profile}"
    key_name = "${var.AWS_SSH_KEY_NAME}"


    tags {
        Name = "kubernetes-${var.aws_cluster_name}-master${count.index}"
        Cluster = "${var.aws_cluster_name}"
        Role = "master"
    }
}

resource "aws_instance" "k8s-etcd" {
    ami = "${var.aws_cluster_ubuntu_16_04_ami}"
    instance_type = "${var.aws_etcd_size}"

    count = "${var.aws_etcd_num}"


    availability_zone = "${element(var.aws_avail_zones,count.index)}"
    subnet_id = "${element(var.aws_public_subnet_ids,count.index)}"

    associate_public_ip_address = true

    vpc_security_group_ids = [ "${module.aws-vpc.aws_security_group}" ]

    key_name = "${var.AWS_SSH_KEY_NAME}"


    tags {
        Name = "kubernetes-${var.aws_cluster_name}-etcd${count.index}"
        Cluster = "${var.aws_cluster_name}"
        Role = "etcd"
    }

}

resource "aws_instance" "k8s-worker" {
    ami = "${var.aws_cluster_ubuntu_16_04_ami}"
    instance_type = "${var.aws_kube_worker_size}"

    count = "${var.aws_kube_worker_num}"

    availability_zone  = "${element(var.aws_avail_zones,count.index)}"
    subnet_id = "${element(var.aws_public_subnet_ids,count.index)}"

    vpc_security_group_ids = [ "${module.aws-vpc.aws_security_group}", "${module.aws-vpc.aws_security_group_k8s_loadbalancer}" ]

    iam_instance_profile = "${module.aws-iam.kube-worker-profile}"
    key_name = "${var.AWS_SSH_KEY_NAME}"


    tags {
        Name = "kubernetes-${var.aws_cluster_name}-worker${count.index}"
        Cluster = "${var.aws_cluster_name}"
        Role = "worker"
    }

}
resource "aws_eip" "workers-eip" {
  count = "${var.aws_kube_worker_num}"
  instance = "${element(aws_instance.k8s-worker.*.id,count.index)}"
}
