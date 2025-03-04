output "instance_ip_addr_public1" {
  value = aws_instance.web_instance1.public_ip
}

output "instance_ip_addr_private1" {
  value = aws_instance.web_instance1.private_ip
}

output "instance_ip_addr_public2" {
  value = aws_instance.web_instance2.public_ip
}

output "instance_ip_addr_private2" {
  value = aws_instance.web_instance2.private_ip
}

output "instance_id1" {
  value = aws_instance.web_instance1.id
}

output "instance_id2" {
  value = aws_instance.web_instance2.id
}