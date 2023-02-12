output "ec2_public_ips" {
    value = module.my-webserver.instance.public_ip
}
