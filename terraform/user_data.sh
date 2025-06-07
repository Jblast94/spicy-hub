#!/bin/bash

# Spicy Hub EC2 User Data Script
# This script sets up the environment for running Spicy Hub on EC2

set -e

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Git
yum install -y git

# Install Node.js (for any frontend build processes)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install NVIDIA Docker (for GPU support)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | tee /etc/yum.repos.d/nvidia-docker.repo
yum install -y nvidia-docker2
systemctl restart docker

# Create application directory
mkdir -p /opt/spicy-hub
cd /opt/spicy-hub

# Clone the repository (replace with your actual repo URL)
# git clone https://github.com/yourusername/spicy-hub.git .

# Create logs directory
mkdir -p logs

# Set up environment variables
cat > .env << EOF
# Database Configuration
DATABASE_URL=postgresql://spicyhub:${DB_PASSWORD}@${DB_HOST}:5432/spicyhub
DATABASE_HOST=${DB_HOST}
DATABASE_PORT=5432
DATABASE_NAME=spicyhub
DATABASE_USER=spicyhub
DATABASE_PASSWORD=${DB_PASSWORD}

# JWT Configuration
JWT_SECRET_KEY=${JWT_SECRET}
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=${STRIPE_PK}
STRIPE_SECRET_KEY=${STRIPE_SK}
STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK}

# AWS Configuration
AWS_REGION=${AWS_REGION}
AWS_S3_BUCKET=${S3_BUCKET}
AWS_CLOUDFRONT_DOMAIN=${CLOUDFRONT_DOMAIN}

# Model Server Configuration
MODEL_SERVER_URL=http://model-server:8000
HUGGINGFACE_TOKEN=${HF_TOKEN}
STABLE_DIFFUSION_MODEL=runwayml/stable-diffusion-v1-5
TEXT_MODEL=microsoft/DialoGPT-medium

# Application Configuration
APP_NAME=Spicy Hub
APP_VERSION=1.0.0
APP_ENVIRONMENT=production
BACKEND_URL=http://backend:8080
FRONTEND_URL=https://${DOMAIN_NAME}
ALLOWED_ORIGINS=https://${DOMAIN_NAME}

# Security Configuration
SECRET_KEY=${SECRET_KEY}
PASSWORD_SALT_ROUNDS=12
RATE_LIMIT_PER_MINUTE=60
MAX_UPLOAD_SIZE=10485760

# Email Configuration
SMTP_HOST=${SMTP_HOST}
SMTP_PORT=587
SMTP_USER=${SMTP_USER}
SMTP_PASSWORD=${SMTP_PASSWORD}
FROM_EMAIL=noreply@${DOMAIN_NAME}

# Redis Configuration
REDIS_URL=redis://redis:6379/0
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

# Celery Configuration
CELERY_BROKER_URL=redis://redis:6379/1
CELERY_RESULT_BACKEND=redis://redis:6379/1

# Rate Limiting
RATE_LIMIT_STORAGE_URL=redis://redis:6379/2

# Content Moderation
CONTENT_MODERATION_ENABLED=true
MODERATION_API_KEY=${MODERATION_API_KEY}

# Monitoring
MONITOR_INTERVAL=60
ALERT_COOLDOWN=300
ALERT_EMAILS=${ALERT_EMAILS}

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
EOF

# Set proper permissions
chown -R ec2-user:ec2-user /opt/spicy-hub
chmod 600 /opt/spicy-hub/.env

# Create systemd service for the application
cat > /etc/systemd/system/spicy-hub.service << EOF
[Unit]
Description=Spicy Hub Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/spicy-hub
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable spicy-hub.service

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/spicy-hub/logs/app.log",
            "log_group_name": "/aws/ec2/spicy-hub/app",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/docker",
            "log_group_name": "/aws/ec2/spicy-hub/docker",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "SpicyHub/EC2",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create a startup script
cat > /opt/spicy-hub/startup.sh << 'EOF'
#!/bin/bash
cd /opt/spicy-hub

# Wait for Docker to be ready
while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker to start..."
    sleep 5
done

# Pull latest images
docker-compose pull

# Start the application
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 30

# Check service health
docker-compose ps
EOF

chmod +x /opt/spicy-hub/startup.sh

# Add to crontab for auto-restart on reboot
echo "@reboot /opt/spicy-hub/startup.sh" | crontab -u ec2-user -

# Log completion
echo "Spicy Hub setup completed at $(date)" >> /var/log/user-data.log