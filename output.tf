output "netbox.ip" {
  value = "${aws_instance.netbox.public_ip}"
}
output "netbox_association.ip" {
  value = "${aws_eip_association.eip_netbox.public_ip}"
}