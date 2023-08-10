output "vpc_id" {
  value = yandex_vpc_network.this.id
}

output "vpc_public_subnets" {
  value = yandex_vpc_subnet.public
}

output "vpc_private_subnets" {
  value = yandex_vpc_subnet.public
}