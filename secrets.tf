resource "aws_secretsmanager_secret" "client_id" {
    name = "astro-app/client-id"
}

resource "aws_secretsmanager_secret_version" "client_id" {
    secret_id     = aws_secretsmanager_secret.client_id.id
    secret_string = "a3f9d21b-7c44-4e8a-9b2e-1d5f6c8a9e3d"
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
    name = "astro-ecs-secrets-access"
    role = aws_iam_role.ecs_task_execution.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = ["secretsmanager:GetSecretValue"]
            Resource = [aws_secretsmanager_secret.client_id.arn]
        }]
    })
}
