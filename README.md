# AWS Karpenter Autoscaler

Small PoC demonstrating autoscaling capabilities

Installation

```
aws configure # set your credentials
terraform init
terraform apply
```

You can play with `instance-category` and/or `capacity-type` on the karpenter.nodepool file and reapply settings for an initial approach to autoscaling parameters.

NGINX application was provided to exercise autoscaling by increasing replicas desired.
