terraform {
  backend "s3" {
    bucket       = "terraform-my-bucket-for-practice"
    key          = "dev/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}