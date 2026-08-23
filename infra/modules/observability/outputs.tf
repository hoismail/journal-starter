output "namespace" {
  description = "Namespace where observability stack is installed"
  value       = var.namespace
}

output "kube_prometheus_stack_release_name" {
  description = "Helm release name for kube-prometheus-stack"
  value       = helm_release.kube_prometheus_stack.name
}

output "loki_release_name" {
  description = "Helm release name for Loki"
  value       = helm_release.loki.name
}

output "tempo_release_name" {
  description = "Helm release name for Tempo"
  value       = helm_release.tempo.name
}

output "otel_collector_release_name" {
  description = "Helm release name for OpenTelemetry Collector"
  value       = helm_release.otel_collector.name
}
