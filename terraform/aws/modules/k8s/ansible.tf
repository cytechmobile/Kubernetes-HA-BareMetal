/*
* Create Kubespray Inventory File
*
*/
data "template_file" "inventory" {
    template = "${file("${path.module}/../../templates/inventory.tpl")}"

    vars {
        public_ip_address_bastion = "${join("\n",formatlist("bastion ansible_ssh_host=%s" , aws_eip.bastion-eip.*.public_ip))}"
        connection_strings_master = "${join("\n",formatlist("%s ansible_ssh_host=%s",aws_instance.k8s-master.*.tags.Name, aws_instance.k8s-master.*.private_ip))}"
        connection_strings_node = "${join("\n", formatlist("%s ansible_ssh_host=%s", aws_instance.k8s-worker.*.tags.Name, aws_instance.k8s-worker.*.private_ip))}"
        connection_strings_etcd = "${join("\n",formatlist("%s ansible_ssh_host=%s", aws_instance.k8s-etcd.*.tags.Name, aws_instance.k8s-etcd.*.private_ip))}"
        list_master = "${join("\n",aws_instance.k8s-master.*.tags.Name)}"
        list_node = "${join("\n",aws_instance.k8s-worker.*.tags.Name)}"
        list_etcd = "${join("\n",aws_instance.k8s-etcd.*.tags.Name)}"
        elb_api_fqdn = "apiserver_loadbalancer_domain_name=\"k8s-${var.installation_name}.${var.k8s_domain_name}\""
        elb_api_port = "loadbalancer_apiserver.port=${var.aws_elb_api_port}"
        kube_insecure_apiserver_address = "kube_apiserver_insecure_bind_address=${var.kube_insecure_apiserver_address}"

    }
}

resource "null_resource" "inventories" {
  triggers {
    template = "${data.template_file.inventory.rendered}"
  }

  provisioner "local-exec" {
      command = "echo '${data.template_file.inventory.rendered}' > ../../../ansible/${var.installation_name}/ansible_inventory"
  }

}
