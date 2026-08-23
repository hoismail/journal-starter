import {
  to = module.eks.aws_eks_access_entry.github_actions
  id = "journal-api-eks-cluster:arn:aws:iam::744763865781:role/JournalApiGitHubTerraformRole"
}

import {
  to = module.observability.kubernetes_namespace_v1.monitoring
  id = "monitoring"
}
