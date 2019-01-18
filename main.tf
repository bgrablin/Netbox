provider "aws" {
  region     = "${var.region}"
}
resource "aws_key_pair" "netbox-pair" {
  key_name = "netbox-pair"
  public_key = "${file("~/.ssh/Netbox/id_rsa.pub")}"
}
 data "aws_ami" "redhat" {
    most_recent = true
    owners = ["309956199498"] // Red Hat's account ID.
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["RHEL-7.*"]
  }
}
resource "aws_instance" "netbox" {
  ami = "${data.aws_ami.redhat.id}"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.sg_netbox.name}"
    ]
  key_name = "netbox-pair"
  associate_public_ip_address = "true"
  connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = "${file(var.ssh_key_private)}"
    }
  user_data = <<-EOF
            #!/bin/bash
            echo netbox.grayanalytics.io > /etc/hostname
            EOF
  tags {
        Name = "Netbox"
        Terraform = "true"
        Environment = "dev"
        AutoOff = "false"
    }
  provisioner "remote-exec" {
    inline = [
          "sudo chmod 600 ~/.ssh/id_rsa",
          "sudo yum-config-manager --enable rhui-REGION-rhel-server-extras",
          "sudo yum-config-manager --enable extras",
          # "sudo yum update -y",
          "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
          "sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
          "sudo yum makecache fast",
          "sudo yum -y install device-mapper-persistent-data wget lvm2 nano yum-utils ntp net-tools git curl docker-ce ansible",
          "sudo systemctl start docker",
          "sudo systemctl enable docker",
          "sudo curl -L \"https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
          "sudo chmod +x /usr/local/bin/docker-compose",
          "sudo groupadd docker",
          "sudo usermod -aG docker $USER",
          # "sudo docker swarm init",
          # "sudo docker swarm join-token --quiet worker > /home/ec2-user/token",
          "git clone https://github.com/bgrablin/Netbox.git",
          "git clone https://github.com/ninech/netbox-docker.git",
          "cd ~/netbox-docker && docker-compose -f ~/Netbox/docker-compose.yml"
          # "ansible-playbook -i /home/ec2-user/Docker/Ansible/hosts /home/ec2-user/Docker/Ansible/main.yml",
      ]
  }
}
resource "aws_eip_association" "eip_netbox" {
  instance_id    = "${aws_instance.netbox.id}"
  allocation_id = "${var.allocation_id}"
}
data "aws_route53_zone" "selected" {
  name         = "${var.hosted_zone}"
}
resource "aws_route53_record" "netbox-ns" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "netbox.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl = "300"
  records = ["${aws_eip_association.eip_netbox.public_ip}"]
}