output "Jenkins-URL" {
  value = "${aws_instance.my-ec2-instance.public_ip}:8080"
}


output "Sonar-Qube URL" {
  value = "${aws_instance.my-ec2-instance.public_ip}:9000"
}