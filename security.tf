resource "aws_security_group" "sg_netbox" {
    name = "sg_netbox"
    description = "Created with Terraform - allow all outgoing traffic"
# allow internet access, but block all incoming traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.cidr_block_internet}"]
    }
    # allow sshd connection
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.cidr_block_internet}"]
    }
    # allow outbound traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # allow http traffic
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 80
        protocol = "tcp"
        to_port = 80
    }
    # allow http traffic
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 8080
        protocol = "tcp"
        to_port = 8080
    }
    # allow https traffic
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 443
        protocol = "tcp"
        to_port = 443
    }
    # allow netbox traffic
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 2377
        protocol = "tcp"
        to_port = 2377
    }
}