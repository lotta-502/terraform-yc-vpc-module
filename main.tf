resource "yandex_vpc_network" "this" {
  folder_id   = var.folder_id
  name        = var.network_name
  description = var.network_description

  labels = var.labels
}

resource "yandex_vpc_gateway" "egress_gateway" {
  name = "${var.network_name}-egress-gateway"
  shared_egress_gateway {}

  labels = var.labels
}

resource "yandex_vpc_route_table" "public" {
  folder_id   = var.folder_id
  name        = "${var.network_name}-public"
  description = "${var.network_name} routing table for public subnets"
  network_id  = yandex_vpc_network.this.id

  labels = var.labels
}

resource "yandex_vpc_route_table" "private" {
  folder_id   = var.folder_id
  name        = "${var.network_name}-private"
  description = "${var.network_name} routing table for private subnets"
  network_id  = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.egress_gateway.id
  }

  labels = var.labels
}

resource "yandex_vpc_subnet" "public" {
  for_each = var.public_subnets

  folder_id      = var.folder_id
  name           = "public-${var.network_name}-${each.key}"
  description    = "${var.network_name} subnet for ${each.key}"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  route_table_id = yandex_vpc_route_table.public.id

  labels = var.labels
}

resource "yandex_vpc_subnet" "private" {
  for_each = var.private_subnets

  folder_id      = var.folder_id
  name           = "private-${var.network_name}-${each.key}"
  description    = "${var.network_name} subnet for ${each.key}"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  route_table_id = yandex_vpc_route_table.private.id

  labels = var.labels
}

resource "yandex_vpc_default_security_group" "this" {
  folder_id   = var.folder_id
  description = "Default VPC security group"
  network_id  = yandex_vpc_network.this.id

  ingress {
    protocol          = "ANY"
    description       = "Communication inside this SG"
    predefined_target = "self_security_group"

  }
  ingress {
    protocol       = "ICMP"
    description    = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol          = "TCP"
    description       = "NLB health check"
    predefined_target = "loadbalancer_healthchecks"
  }
  egress {
    protocol       = "ANY"
    description    = "To internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  labels = var.labels
}
