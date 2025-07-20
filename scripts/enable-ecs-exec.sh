#!/bin/bash

# Script สำหรับเปิดใช้งาน ECS Exec และ exec เข้าไปใน Kong Fargate task
# ต้องรัน terraform apply ก่อนเพื่อเปิดใช้งาน enable_execute_command

set -e

# Configuration
CLUSTER_NAME="kong-cluster"
SERVICE_NAME="kong-cluster-service"
REGION="ap-southeast-1"
PROFILE="bluebik"

echo "🔧 กำลังเปิดใช้งาน ECS Exec สำหรับ Kong cluster..."

# 1. ตรวจสอบว่า AWS CLI และ Session Manager plugin ติดตั้งแล้ว
check_dependencies() {
    echo "📋 ตรวจสอบ dependencies..."
    
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI ไม่ได้ติดตั้ง"
        exit 1
    fi
    
    if ! command -v session-manager-plugin &> /dev/null; then
        echo "❌ Session Manager plugin ไม่ได้ติดตั้ง"
        echo "📥 ติดตั้งได้จาก: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
        exit 1
    fi
    
    echo "✅ Dependencies ครบถ้วน"
}

# 2. ตรวจสอบ AWS credentials
check_aws_credentials() {
    echo "🔐 ตรวจสอบ AWS credentials..."
    
    if ! aws sts get-caller-identity --profile $PROFILE &> /dev/null; then
        echo "❌ ไม่สามารถเชื่อมต่อ AWS ได้"
        exit 1
    fi
    
    echo "✅ AWS credentials ใช้งานได้"
}

# 3. เปิดใช้งาน ECS Exec ใน Terraform
enable_ecs_exec() {
    echo "🚀 เปิดใช้งาน ECS Exec ใน Terraform..."
    
    cd terraform
    
    # แก้ไขไฟล์ main.tf ใน kong module
    sed -i '' 's/enable_execute_command = false/enable_execute_command = true/' modules/kong/main.tf
    
    echo "✅ แก้ไข Terraform configuration เรียบร้อย"
    echo "📝 อย่าลืมรัน 'terraform apply' เพื่อ apply การเปลี่ยนแปลง"
}

# 4. ดูรายการ tasks
list_tasks() {
    echo "📋 รายการ ECS tasks:"
    
    TASKS=$(aws ecs list-tasks \
        --cluster $CLUSTER_NAME \
        --service-name $SERVICE_NAME \
        --region $REGION \
        --profile $PROFILE \
        --query 'taskArns' \
        --output text)
    
    if [ -z "$TASKS" ]; then
        echo "❌ ไม่พบ tasks ที่รันอยู่"
        return 1
    fi
    
    echo "Tasks found:"
    for task in $TASKS; do
        echo "  - $task"
    done
    
    # ใช้ task แรก
    TASK_ARN=$(echo $TASKS | cut -d' ' -f1)
    echo "🎯 ใช้ task: $TASK_ARN"
}

# 5. Exec เข้าไปใน task
exec_into_task() {
        echo "🔗 กำลังเชื่อมต่อเข้าไปใน Kong container..."
    
    echo "Command: aws ecs execute-command --cluster $CLUSTER_NAME --task $TASK_ARN --container kong --command /bin/bash --interactive --region $REGION --profile $PROFILE"
    
    aws ecs execute-command \
        --cluster $CLUSTER_NAME \
        --task $TASK_ARN \
        --container kong \
        --command /bin/bash \
        --interactive \
        --region $REGION \
        --profile $PROFILE
}

# 6. ดู logs
view_logs() {
    echo "📊 ดู CloudWatch logs:"
    
    aws logs tail "/ecs/$CLUSTER_NAME" \
        --region $REGION \
        --profile $PROFILE \
        --follow
}

# Main menu
show_menu() {
    echo ""
    echo "🐳 Kong ECS Exec Manager"
    echo "========================"
    echo "1. ตรวจสอบ dependencies"
    echo "2. เปิดใช้งาน ECS Exec (แก้ไข Terraform)"
    echo "3. ดูรายการ tasks"
    echo "4. Exec เข้าไปใน Kong container"
    echo "5. ดู CloudWatch logs"
    echo "6. ทำทั้งหมด (1-4)"
    echo "0. ออกจากโปรแกรม"
    echo ""
    read -p "เลือกตัวเลือก (0-6): " choice
    
    case $choice in
        1)
            check_dependencies
            check_aws_credentials
            ;;
        2)
            enable_ecs_exec
            ;;
        3)
            list_tasks
            ;;
        4)
            if list_tasks; then
                exec_into_task
            fi
            ;;
        5)
            view_logs
            ;;
        6)
            check_dependencies
            check_aws_credentials
            enable_ecs_exec
            if list_tasks; then
                exec_into_task
            fi
            ;;
        0)
            echo "👋 ออกจากโปรแกรม"
            exit 0
            ;;
        *)
            echo "❌ ตัวเลือกไม่ถูกต้อง"
            ;;
    esac
}

# ถ้าไม่มี arguments ให้แสดง menu
if [ $# -eq 0 ]; then
    show_menu
else
    # ถ้ามี arguments ให้รันตามที่ระบุ
    case $1 in
        "check")
            check_dependencies
            check_aws_credentials
            ;;
        "enable")
            enable_ecs_exec
            ;;
        "list")
            list_tasks
            ;;
        "exec")
            if list_tasks; then
                exec_into_task
            fi
            ;;
        "logs")
            view_logs
            ;;
        *)
            echo "Usage: $0 [check|enable|list|exec|logs]"
            exit 1
            ;;
    esac
fi 


aws ecs execute-command \
    --cluster kong-cluster \
    --task arn:aws:ecs:ap-southeast-1:644789170005:task/kong-cluster/e83603c8821b4f9685391385939cb215 \
    --container kong \
    --command "/bin/bash" \
    --interactive \
    --region ap-southeast-1 \
    --profile bluebik

aws ecs describe-services --cluster kong-cluster --services kong-cluster-service --region ap-southeast-1 --profile bluebik | grep enableExecuteCommand

aws ecs update-service --cluster kong-cluster --service kong-cluster-service --region ap-southeast-1 --profile bluebik --force-new-deployment
