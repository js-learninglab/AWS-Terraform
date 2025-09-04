provider "aws" {
    region = "us-west-2"
}

data "aws_ami" "windows" {
    most_recent = true

    filter {
        name = "name"
        values = ["Windows_Server-2022-English-Full-Base-*"]
    }

    owners = ["801119661308"]
}

resource "aws_instance" "app_server" {
    ami = data.aws_ami.windows.id
    instance_type = var.instance_type

    tags = {
        Name = var.instance_name
    }
}