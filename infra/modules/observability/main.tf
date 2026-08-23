resource "helm_release" "kube_prometheus_stack" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = true
  skip_crds        = false
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = var.namespace

  values = [
    var.loki_values
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = var.namespace
}

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  namespace  = var.namespace

  values = [
    var.otel_collector_values
  ]

  depends_on = [
    helm_release.tempo,
    helm_release.loki,
  ]
}

import {
  to = aws_eks_access_entry.github_actions
  id = "journal-api-eks-cluster:arn:aws:iam::744763865781:role/JournalApiGitHubTerraformRole"
}
