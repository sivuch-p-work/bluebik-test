resource "aws_secretsmanager_secret" "kong" {
    name = "${var.secret_name}-storage"

    tags = {
        Name = "${var.secret_name}-storage"
    }
}

resource "random_id" "secret_suffix" {
    byte_length = 8
}

resource "aws_secretsmanager_secret_version" "kong" {
    secret_id = aws_secretsmanager_secret.kong.id
    secret_string = jsonencode({
        KONG_USER         = var.kong_user
        KONG_PASSWORD     = var.kong_password
        KONG_POSTGRES_URL = var.kong_postgres_url
    })
} 