package main

import rego.v1

workload_containers := input.spec.containers if input.kind == "Pod"

workload_containers := input.spec.template.spec.containers if input.kind == "Deployment"

deny contains msg if {
	some c in workload_containers
	not c.resources.limits
	msg := sprintf("%s %s: container %q has no resources.limits", [input.kind, input.metadata.name, c.name])
}

deny contains msg if {
	some c in workload_containers
	not contains(c.image, ":")
	msg := sprintf("%s %s: image %q has no tag", [input.kind, input.metadata.name, c.image])
}

deny contains msg if {
	some c in workload_containers
	endswith(c.image, ":latest")
	msg := sprintf("%s %s: image %q uses the latest tag", [input.kind, input.metadata.name, c.image])
}

warn contains msg if {
	some c in workload_containers
	not c.securityContext.runAsNonRoot
	msg := sprintf("%s %s: container %q does not set runAsNonRoot", [input.kind, input.metadata.name, c.name])
}
