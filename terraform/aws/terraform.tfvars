#Global Vars
installation_name = "cytechmobile"
aws_cluster_name = "mcore"
AWS_DEFAULT_REGION= "eu-west-1"
AWS_SSH_KEY_NAME="k8s" # the name of the EC2 key pair that you have created. MUST exist in your region.
k8s_domain_name = "cytechmobile.com"

#VPC Vars
vpc_id = "" # Fill in your existing VPC ID
aws_public_subnet_ids = ["", "", ""] # Fill in your existing Network Subnets
aws_avail_zones = ["eu-west-1a","eu-west-1b","eu-west-1c"]

#Bastion Host
aws_bastion_debian_jessie_ami = "ami-402f1a33"
aws_bastion_size = "t2.nano"


#Kubernetes Cluster

aws_kube_master_num = 3
aws_kube_master_size = "t2.small" # minimum t2.small

aws_etcd_num = 3
aws_etcd_size = "t2.micro"

aws_kube_worker_num = 3
aws_kube_worker_size = "t2.medium"

aws_cluster_ubuntu_16_04_ami = "ami-674cbc1e"

#Settings AWS ELB

aws_elb_api_port = 9443
k8s_secure_api_port = 9443
kube_insecure_apiserver_address = "0.0.0.0"

service_loadbalancer_http_port = 31999
service_loadbalancer_https_port = 31943