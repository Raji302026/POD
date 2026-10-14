terraform {
  required_version = ">= 1.5.0"
}

variable "app_name" {
  type        = string
  description = "Name of the practice app"
  default     = "robility-practice"
}

variable "environment" {
  type        = string
  description = "Target environment"
  default     = "dev"
}

resource "terraform_data" "app" {
  input = "${var.app_name}-${var.environment}"
}

output "app_id" {
  value = terraform_data.app.output
}
variable "bad"   {  type=string }
