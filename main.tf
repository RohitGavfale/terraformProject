provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "alicloud_instance_types" "instance_type" {
  instance_type_family = "ecs.n4"
  cpu_core_count = "1"
  memory_size = "2"
}

resource "alicloud_security_group" "group" {
  name = "${var.short_name}"
  description = "New security group"
}

resource "alicloud_security_group_rule" "allow_http_80" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "80/80"
  priority = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip = "0.0.0.0/0"
}


resource "alicloud_security_group_rule" "allow_https_443" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "443/443"
  priority = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_http_22" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_disk" "disk" {
  availability_zone = "${alicloud_instance.instance.0.availability_zone}"
  category = "${var.disk_category}"
  size = "${var.disk_size}"
  count = "${var.count}"
}

resource "null_resource" "instance" {

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  
  connection {
    host = "${alicloud_instance.instance.public_ip}"
    type     = "ssh"
    user     = "root"
    password = "${var.ecs_password}"
   
  }
 
}
resource "alicloud_instance" "instance" {
  instance_name = "${var.short_name}-${var.role}-${format(var.count_format, count.index+1)}"
  host_name = "${var.short_name}-${var.role}-${format(var.count_format, count.index+1)}"
  image_id = "${var.image_id}"
  instance_type = "${data.alicloud_instance_types.instance_type.instance_types.0.id}"
  count = "${var.count}"
  availability_zone = "${var.availability_zones}"
  security_groups = ["${alicloud_security_group.group.*.id}"]

  internet_charge_type = "${var.internet_charge_type}"
  internet_max_bandwidth_out = "${var.internet_max_bandwidth_out}"
  io_optimized = "optimized"
  password = "${var.ecs_password}"

  allocate_public_ip = "${var.allocate_public_ip}"

  instance_charge_type = "PostPaid"
  system_disk_category = "cloud_efficiency"


  tags {
    role = "${var.role}"
    dc = "${var.datacenter}"
  }
  
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
     "sudo apt-get update",
     "sudo apt-get install httpd",
	 "sudo apt-get install -y apache2",
	 "sudo apt-get install -y php5 libapache2-mod-php5 php5-mcrypt"
   ],
   connection 
	{
		host = "${alicloud_instance.instance.public_ip}"
		type     = "ssh"
		user     = "root"
		password = "${var.ecs_password}"
	}
  }
  
    provisioner "file" 
	{
		source      = "${var.source_dir}"
		destination = "/var/www/html/"
		
		connection 
		{
			host = "${alicloud_instance.instance.public_ip}"
			type     = "ssh"
			user     = "root"
			password = "${var.ecs_password}"
		}
	}
 
}

resource "alicloud_disk_attachment" "instance-attachment" {
  count = "${var.count}"
  disk_id = "${element(alicloud_disk.disk.*.id, count.index)}"
  instance_id = "${element(alicloud_instance.instance.*.id, count.index)}"
  
}


 