# Kong Secrets
resource "aws_secretsmanager_secret" "kong" {
    name = "${var.secret_name}-${random_id.secret_suffix.hex}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"

    tags = {
        Name = "${var.secret_name}-${random_id.secret_suffix.hex}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
    }
}

# Random suffix for unique secret names
resource "random_id" "secret_suffix" {
    byte_length = 8
}

# Kong Secret Values
resource "aws_secretsmanager_secret_version" "kong" {
    secret_id = aws_secretsmanager_secret.kong.id
    secret_string = jsonencode({
        KONG_USER         = var.kong_user
        KONG_PASSWORD     = var.kong_password
        KONG_POSTGRES_URL = var.kong_postgres_url
    })
} 