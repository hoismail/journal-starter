variable "namespace" {
  description = "Kubernetes namespace where observability components are installed"
  type        = string
  default     = "monitoring"
}

variable "loki_values" {
  description = "Helm values YAML for Loki"
  type        = string
}

variable "otel_collector_values" {
  description = "Helm values YAML for OpenTelemetry Collector"
  type        = string
}
