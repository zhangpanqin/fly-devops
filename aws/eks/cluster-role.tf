resource "kubernetes_cluster_role" "team_clusterrole" {

  metadata {
    name = "admin-clusterrole"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}
