locals {
  common_tags = {
    Environment    = var.env
    CostCenter     = ""
    CreateBy       = "Terraform"
    CreateLocation = "https://bitbucket.alsac.stjude.org:8443/projects/CLAWS/repos/automation-jenkins/"
    Application    = "Automation-Jenkins"
    ContactEmail   = ""
    CreateDate     = ""
    Compliance     = ""
  }
}
