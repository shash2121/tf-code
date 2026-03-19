terraform {
  backend "s3" {
    bucket  = "tf-27jul"
    key     = "terraform/state.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}