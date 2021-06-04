variable "priv_1a_subnet" {
    default = "subnet-0da5185328e705af9"
}

variable "priv_lb_subnet" {
    default = "subnet-0c347a23f8c264f4a"
}

variable "priv_1a_subnet_cidr" {
    default = "172.19.4.0/23"
}

variable "vpc_id" {
    default = "vpc-0f7d1043cd892f050"
}

variable "jenkins_role" {
    default = "arn:aws:iam::143269240300:role/alsac-managed/jenkins_automation_role"
}

variable "env" {
    default = "util"
}

variable "account_numbers" {
  default = {
    "pci"  = "043631176008"
    "dev"  = "117183459779"
    "util" = "143269240300"
    "sec"  = "181347727718"
    "sand" = "367781776929"
    "qa"   = "441686764717"
    "prod" = "566421363352"
  }
}