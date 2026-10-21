package pipeline

import rego.v1

secret_words := ["password", "secret", "apikey", "api-key", "token"]

deny contains msg if {
	some name, value in input.variables
	some word in secret_words
	contains(lower(name), word)
	is_string(value)
	not startswith(value, "$(")
	msg := sprintf("variable '%s' looks like a secret with a hardcoded value; read it from Key Vault", [name])
}
