# Terraform-IGNITE

Infrastructure for the astro-app demo: VPC, public subnets across two AZs, an
Application Load Balancer, an ECS Fargate service running the NGINX demo
container, a private ECR repository, Secrets Manager-backed configuration,
and a CloudWatch CPU alarm.

## CI/CD

- `.github/workflows/deploy.yml` — on push to `develop`: pulls the public
  `nginxdemos/hello` image, tags it uniquely, pushes it to ECR, then runs
  `terraform apply` to roll the new image out to the ECS service and waits
  for the service to stabilize.
- `.github/workflows/pr-check.yml` — on pull requests: validates Terraform
  formatting, runs `terraform plan`, and never deploys.
