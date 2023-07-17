plugin "aws" {
    enabled = true
    version = "0.23.1"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
    enabled = true
    version = "0.3.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule "terraform_comment_syntax" {
    enabled = true
}

rule "terraform_documented_outputs" {
    enabled = false
}

rule "terraform_documented_variables" {
    enabled = false
}

rule "terraform_naming_convention" {
    enabled = true
}

rule "terraform_unused_required_providers" {
    enabled = true
}

rule "terraform_standard_module_structure" {
    enabled = false
}
