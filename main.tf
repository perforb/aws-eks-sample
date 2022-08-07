locals {
  cluster_name    = "eks-example"
  cluster_version = "1.22"
}

provider "aws" {
  region = "ap-northeast-1"
}
