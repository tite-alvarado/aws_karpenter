data "kubectl_path_documents" "applications" {
  pattern = "./application.*.yaml"
}

resource "kubectl_manifest" "applications" {
  for_each  = toset(data.kubectl_path_documents.applications.documents)
  yaml_body = each.value

  depends_on = [module.eks, helm_release.karpenter]
}

