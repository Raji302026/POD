variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

resource "terraform_data" "app" {
  input = "${var.app_name}-${var.environment}"
}

output "app_id" {
  value = terraform_data.app.output
}
