package kubernetes.security

deny[msg] {
  input.kind == "Deployment"
  not input.spec.template.spec.containers[_].securityContext.runAsNonRoot
  msg := "Containers must run as non-root"
}
