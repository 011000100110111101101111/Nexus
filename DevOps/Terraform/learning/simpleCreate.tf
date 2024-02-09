# resource = Block Name
# local = Provider
# file = Resource
# local_file = Resource Type
# pet = Resource Name
# Arguments = 'content = "We love pets!"'
resource "local_file" "pet" {
  filename        = "/root/pets.txt"
  content         = "We love pets!"
  file_permission = "0700"
}


# Simple aws-ec2 example
resource "aws_instance" "webserver" {
  ami           = "ami-rfandomletsters"
  instance_type = "t2.micro"
}

# Simple aws-bucket example
resource "aws_s3_bucket" "data" {
  bucket = "webserver-bucket-org-2208"
  acl    = "private"
}


# Steps to accomplish deployment,
# Create resource file
# Run init command -> terraform init
# Ensure Plan is good to go -> terraform plan
# To deploy the infrastructure -> terraform apply
# To destroy the infrastructure -> terraform destroy
