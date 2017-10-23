data "aws_route53_zone" "your_zone" {
  zone_id = "${var.aws_route53_zone_id}"
  provider = "aws.route53_account"
}
resource "aws_route53_record" "k8s_fqdn" {
  zone_id = "${data.aws_route53_zone.your_zone.id}"
  name = "k8s-${var.installation_name}.${var.k8s_domain_name}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.k8s-master.*.public_ip}"]
  provider = "aws.route53_account"
  count = "${var.aws_kube_master_num}"
  depends_on = ["aws_instance.k8s-master"]
}
resource "aws_route53_record" "workers_fqdn" {
  zone_id = "${data.aws_route53_zone.your_zone.id}"
  name = "workers-${var.installation_name}.${var.k8s_domain_name}"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.workers-eip.*.public_ip}"]
  provider = "aws.route53_account"
  depends_on = ["aws_eip.workers-eip"]
}

# An example of setting up the DNS for a new service we will expose through the Service LoadBalancer.
# It just needs to point to the K8s worker nodes. The SLB will take care of the virtual hosting.

resource "aws_route53_record" "grafana_fqdn" {
  zone_id = "${data.aws_route53_zone.your_zone.id}"
  name = "grafana-${var.installation_name}.${var.k8s_domain_name}"
  type = "A"
  provider = "aws.route53_account"

  alias {
    name = "${aws_route53_record.workers_fqdn.name}"
    zone_id = "${aws_route53_record.workers_fqdn.zone_id}"
    evaluate_target_health = true
  }
  depends_on = ["aws_route53_record.workers_fqdn"]

}


resource "aws_route53_record" "bastion_fqdn" {
  zone_id = "${data.aws_route53_zone.your_zone.id}"
  name = "k8s-bastion${count.index}-${var.installation_name}.${var.k8s_domain_name}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_eip.bastion-eip.*.public_ip,count.index)}"]
  provider = "aws.route53_account"
  count = "${length(var.aws_public_subnet_ids)}"
  depends_on = ["aws_eip.bastion-eip"]
}
