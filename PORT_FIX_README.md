# การแก้ไขปัญหา Port Mismatch ใน ALB Target Group

## ปัญหาที่พบ

เดิมที ALB target group ตั้งค่า port = 80 แต่ services ต่างๆ run ที่ port ต่างกัน:
- **Backend service**: port 8080
- **Kong service**: port 8000

ทำให้เกิดปัญหา port mismatch และ traffic ไม่สามารถเข้าถึง services ได้

## การแก้ไข

### 1. สร้าง Target Group แยก

แก้ไข `terraform/modules/alb/main.tf`:

```hcl
# Target Group for Backend (port 8080)
resource "aws_lb_target_group" "backend" {
    name        = "${var.name}-backend-tg"
    port        = 8080  # ตรงกับ backend service
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"
    
    health_check {
        path = "/healthz"  # Backend health check endpoint
        # ... other settings
    }
}

# Target Group for Kong (port 8000)
resource "aws_lb_target_group" "kong" {
    name        = "${var.name}-kong-tg"
    port        = 8000  # ตรงกับ kong service
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"
    
    health_check {
        path = "/"  # Kong proxy endpoint
        # ... other settings
    }
}
```

### 2. Explicit Path-based Routing ด้วย Rules

ตั้งค่า ALB listener และ rules เพื่อ route traffic อย่างชัดเจน:

```hcl
# ALB Listener with error response as default
resource "aws_lb_listener" "main" {
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "No matching route found"
            status_code  = "404"
        }
    }
}

# Backend API routes (priority 100 - ตรวจสอบก่อน)
resource "aws_lb_listener_rule" "backend" {
    priority = 100
    
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.backend.arn
    }
    
    condition {
        path_pattern {
            values = ["/api/*", "/test", "/db-check", "/redis-check"]
        }
    }
}

# Kong catch-all route (priority 200 - ตรวจสอบหลัง)
resource "aws_lb_listener_rule" "kong" {
    priority = 200
    
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.kong.arn
    }
    
    condition {
        path_pattern {
            values = ["/*"]  # catch-all pattern
        }
    }
}
```

### 3. อัปเดต Module References

แก้ไข `terraform/main.tf`:

```hcl
# Kong Cluster
module "kong" {
    alb_target_group_arn = module.alb.kong_target_group_arn  # ใช้ kong target group
}

# Backend Cluster  
module "backend" {
    alb_target_group_arn = module.alb.backend_target_group_arn  # ใช้ backend target group
}
```

### 4. อัปเดต Outputs

แก้ไข `terraform/modules/alb/outputs.tf`:

```hcl
output "backend_target_group_arn" {
    value = aws_lb_target_group.backend.arn
}

output "kong_target_group_arn" {
    value = aws_lb_target_group.kong.arn
}
```

## ผลลัพธ์

หลังจากแก้ไขแล้ว:

1. **Backend API calls** (`/api/*`, `/test`, `/db-check`, `/redis-check`) จะถูก route ไปยัง backend service ที่ port 8080
2. **Other traffic** (`/*`) จะถูก route ไปยัง Kong gateway ที่ port 8000
3. **Unmatched traffic** จะได้รับ 404 error response
4. **Health checks** จะทำงานได้ถูกต้องสำหรับทั้งสอง services

## การทำงานของ Rules

### Priority-based Routing:
- **Priority 100**: Backend rules (ตรวจสอบก่อน)
- **Priority 200**: Kong catch-all rule (ตรวจสอบหลัง)
- **Default**: 404 error response

### Flow:
```
1. Traffic เข้า ALB
2. ตรวจสอบ Backend rules (priority 100)
   - ถ้า match → ไป Backend (port 8080)
3. ตรวจสอบ Kong rule (priority 200)
   - ถ้า match → ไป Kong (port 8000)
4. ถ้าไม่ match → 404 error
```

## การ Deploy

```bash
cd terraform
terraform plan
terraform apply
```

## การทดสอบ

```bash
# Test backend endpoints
curl http://<alb-dns-name>/test
curl http://<alb-dns-name>/db-check
curl http://<alb-dns-name>/redis-check

# Test Kong gateway
curl http://<alb-dns-name>/

# Test unmatched route (ควรได้ 404)
curl http://<alb-dns-name>/unknown-path
``` 