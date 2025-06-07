# Spicy Hub - Adult Content Platform

A modern, scalable adult content platform with AI-powered image and text generation, built for AWS deployment with cost optimization in mind.

## 🚀 Features

- **AI Content Generation**: NSFW image generation using Stable Diffusion
- **Text Generation**: Adult-themed text content using DialoGPT
- **Premium Subscriptions**: Stripe-powered subscription management
- **Affiliate Program**: Built-in affiliate tracking and commission system
- **User Management**: JWT-based authentication with user profiles
- **Content Storage**: AWS S3 with CloudFront CDN
- **Scalable Infrastructure**: Auto-scaling EC2 instances with spot pricing
- **Cost Optimized**: Aurora Serverless, intelligent S3 tiering, spot instances

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudFront    │────│  Application     │────│   RDS Aurora    │
│      (CDN)      │    │  Load Balancer   │    │   Serverless    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                       ┌────────┴────────┐
                       │                 │
              ┌─────────────┐    ┌─────────────┐
              │   Backend   │    │ Model Server│
              │  (FastAPI)  │    │ (GPU/Spot)  │
              └─────────────┘    └─────────────┘
                       │                 │
              ┌─────────────┐    ┌─────────────┐
              │    Redis    │    │     S3      │
              │   (Cache)   │    │  (Storage)  │
              └─────────────┘    └─────────────┘
```

## 💰 Cost Optimization

- **Spot Instances**: Up to 90% savings on GPU instances
- **Aurora Serverless**: Pay only for database usage
- **S3 Intelligent Tiering**: Automatic cost optimization
- **CloudFront**: Reduced bandwidth costs
- **Auto Scaling**: Scale down during low usage

**Estimated Monthly Costs:**
- Development: $50-100
- Production (low traffic): $200-400
- Production (high traffic): $800-1500

## 🛠️ Prerequisites

### Required Tools
- [AWS CLI](https://aws.amazon.com/cli/) v2.0+
- [Terraform](https://www.terraform.io/) v1.0+
- [Docker](https://www.docker.com/) v20.0+
- [Node.js](https://nodejs.org/) v16+ (for local development)
- [Python](https://www.python.org/) v3.11+

### AWS Account Setup
1. Create an AWS account
2. Configure AWS CLI: `aws configure`
3. Ensure you have permissions for:
   - EC2, VPC, ALB
   - RDS, S3, CloudFront
   - IAM, ECR
   - Auto Scaling

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/Jblast94/spicy-hub.git
cd spicy-hub
cp .env.example .env
```

### 2. Configure Environment
Edit `.env` file with your settings:
```bash
# Required: Update these values
STRIPE_SECRET_KEY=sk_live_your_stripe_key
STRIPE_PUBLISHABLE_KEY=pk_live_your_stripe_key
JWT_SECRET=your-super-secret-jwt-key
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
```

### 3. Deploy to AWS
```bash
# Make deploy script executable
chmod +x deploy.sh

# Run full deployment
./deploy.sh
```

### 4. Local Development (Optional)
```bash
# Start local environment
docker-compose up -d

# Access the application
open http://localhost
```

## 📁 Project Structure

```
spicy-hub/
├── backend/                 # FastAPI backend
│   ├── main.py             # Main application
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile         # Backend container
│   └── alembic/           # Database migrations
├── frontend/               # HTML/JS frontend
│   └── index.html         # Single page application
├── model-server/          # AI model server
│   ├── main.py           # Model serving API
│   ├── requirements.txt  # ML dependencies
│   └── Dockerfile       # Model server container
├── terraform/            # Infrastructure as code
│   ├── main.tf          # AWS resources
│   └── user_data.sh     # EC2 initialization
├── nginx/               # Reverse proxy config
│   └── nginx.conf      # Nginx configuration
├── docker-compose.yml  # Local development
├── deploy.sh          # Deployment script
└── .env.example      # Environment template
```

## 🔧 Configuration

### Environment Variables
Copy `.env.example` to `.env` and configure:

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db

# Authentication
JWT_SECRET=your-secret-key

# Payment Processing
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...

# AWS Services
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
S3_BUCKET=your-bucket-name

# AI Models
MODEL_SERVER_URL=http://model-server:8000
```

### Stripe Setup
1. Create a [Stripe account](https://stripe.com)
2. Get your API keys from the dashboard
3. Configure webhook endpoints for subscription events
4. Set up products and pricing in Stripe dashboard

### AWS Setup
1. Create S3 bucket for content storage
2. Set up IAM user with appropriate permissions
3. Configure CloudFront distribution (optional)
4. Set up RDS Aurora Serverless database

## 🚀 Deployment

### Local Development
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Deployment
```bash
# Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Deploy application
./deploy.sh
```

## 💳 Monetization Features

### Subscription Tiers
- **Free**: 5 generations per day
- **Premium ($9.99/month)**: Unlimited generations, higher quality
- **Pro ($19.99/month)**: Priority processing, custom models

### Affiliate Program
- 30% commission on referrals
- Real-time tracking and analytics
- Automated payouts via Stripe
- External affiliate integration

### Additional Revenue Streams
- Pay-per-generation credits
- Custom content requests
- NFT marketplace integration
- Premium model access

## 🔒 Security

### Authentication
- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting on API endpoints
- CORS protection

### Content Security
- Age verification (18+)
- Content moderation filters
- NSFW warnings
- Secure file storage in S3

### Data Protection
- HTTPS encryption
- Database encryption at rest
- PII data anonymization
- GDPR compliance features

## 📊 Monitoring

### Health Checks
- Application health endpoints
- Database connectivity checks
- Model server status monitoring
- S3 storage availability

### Metrics
- User registration and engagement
- Generation success rates
- Revenue and conversion tracking
- System performance metrics

### Alerts
- High error rates
- System resource usage
- Failed payments
- Model server downtime

## 🧪 Testing

### Load Testing
```bash
# Run load tests
k6 run load-test.yml
```

### API Testing
```bash
# Test backend endpoints
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## 🔧 Troubleshooting

### Common Issues

**Database Connection Errors**
- Check DATABASE_URL environment variable
- Ensure PostgreSQL is running
- Verify network connectivity

**Model Loading Failures**
- Check GPU availability
- Verify model cache directory permissions
- Ensure sufficient disk space

**Stripe Integration Issues**
- Verify API keys are correct
- Check webhook endpoint configuration
- Ensure test/live mode consistency

### Debug Mode
```bash
# Enable debug logging
export DEBUG=true
docker-compose up
```

## 📈 Scaling

### Horizontal Scaling
- Multiple backend instances behind load balancer
- Separate model server instances for different models
- Redis cluster for session management
- CDN for static content delivery

### Vertical Scaling
- GPU instances for model server
- High-memory instances for large models
- SSD storage for faster I/O

### Cost Optimization
- Spot instances for non-critical workloads
- Auto-scaling based on demand
- S3 intelligent tiering
- CloudFront caching

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Development Setup
```bash
# Clone your fork
git clone https://github.com/yourusername/spicy-hub.git

# Install dependencies
cd backend && pip install -r requirements.txt
cd ../model-server && pip install -r requirements.txt

# Run tests
pytest
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Legal Disclaimer

This platform is intended for adult content generation and must comply with:
- Local and international laws
- Age verification requirements (18+)
- Content moderation guidelines
- Platform terms of service

Users are responsible for ensuring compliance with applicable laws and regulations.

## 🆘 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact support@spicyhub.com

## 🗺️ Roadmap

### Phase 1 (Current)
- ✅ Basic AI generation
- ✅ User authentication
- ✅ Payment processing
- ✅ AWS deployment

### Phase 2 (Next)
- 🔄 Video generation
- 🔄 Advanced model fine-tuning
- 🔄 Mobile app
- 🔄 API marketplace

### Phase 3 (Future)
- 📋 VR/AR integration
- 📋 Blockchain/NFT features
- 📋 Multi-language support
- 📋 Advanced analytics

---

**Built with ❤️ for the adult content creator community**