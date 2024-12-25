variable "servername" {
  description = "Sever Name"
  type = string
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "ami" {
  description = "EC2 Image"
  type        = string
}

variable "key_name" {
  description = "key Value Pair"
  type        = string
}

variable "volume_size" {
    description = "Volume Size"
    type = string 
}