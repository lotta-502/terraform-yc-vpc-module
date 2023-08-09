resource "yandex_vpc_network" "this" {
  folder_id   = var.folder_id
  name        = var.network_name
  description = var.network_description

  labels = var.labels
}

resource "yandex_vpc_gateway" "egress_gateway" {
  folder_id = var.folder_id
  name      = "${var.network_name}-egress-gateway"
  shared_egress_gateway {}

  labels = var.labels
}

resource "yandex_vpc_route_table" "public" {
  folder_id   = var.folder_id
  name        = "${var.network_name}-public"
  description = "Routing table for ${var.network_name} public subnets"
  network_id  = yandex_vpc_network.this.id

  labels = var.labels
}

resource "yandex_vpc_route_table" "private" {
  folder_id   = var.folder_id
  name        = "${var.network_name}-private"
  description = "Routing table for ${var.network_name} private subnets"
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
  name           = "${var.network_name}-public-${each.key}"
  description    = "${var.network_name} public subnet:${each.key}"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  route_table_id = yandex_vpc_route_table.public.id

  labels = var.labels
}

resource "yandex_vpc_subnet" "private" {
  for_each = var.private_subnets

  folder_id      = var.folder_id
  name           = "${var.network_name}-private-${each.key}"
  description    = "${var.network_name} private subnet:${each.key}"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  route_table_id = yandex_vpc_route_table.private.id

  labels = var.labels
}
