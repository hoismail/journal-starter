resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  skip_crds  = false
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    var.loki_values
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
}

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    var.otel_collector_values
  ]

  depends_on = [
    helm_release.tempo,
    helm_release.loki,
  ]
}
