terraform {
  backend "gcs" {
    bucket = "bucket-rd-dev-tfstate"
    prefix = "terraform/state"
  }
}
