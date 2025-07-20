variable "secret_name" {
    type = string
}

variable "kong_user" {
    type = string
    default = "kong"
}

variable "kong_password" {
    type = string
    sensitive = true
}

variable "kong_postgres_url" {
    type = string
    default = ""
} 