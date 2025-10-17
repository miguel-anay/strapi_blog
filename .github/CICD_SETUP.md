# CI/CD Pipeline Setup Guide

This document provides comprehensive instructions for configuring the GitHub Actions CI/CD pipeline for your Strapi v5.24.1 application.

## Overview

The CI/CD pipeline consists of:
- **Continuous Integration (CI)**: Validates code quality, runs tests, and builds the application
- **Continuous Deployment (CD)**: Deploys to Docker Hub or AWS EC2 based on configuration

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Push/PR Event                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    CI Job (Always Runs)                      │
│  • Install dependencies                                      │
│  • TypeScript type checking                                  │
│  • ESLint (if configured)                                    │
│  • Run tests (if available)                                  │
│  • Build Strapi admin panel                                  │
│  • Upload build artifacts                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ├─────────────────┬─────────────────────┐
                      ▼                 ▼                     ▼
        ┌─────────────────────┐ ┌──────────────────┐ ┌──────────────────┐
        │  Docker Hub Deploy  │ │   EC2 Deploy     │ │ Status Report    │
        │  (if DEPLOY_TARGET  │ │ (if DEPLOY_TARGET│ │ (Always Runs)    │
        │   = 'docker')       │ │   = 'ec2')       │ │                  │
        └─────────────────────┘ └──────────────────┘ └──────────────────┘
```

## GitHub Secrets Configuration

### Required Secrets for All Deployments

Navigate to your GitHub repository: **Settings → Secrets and variables → Actions → New repository secret**

#### 1. Strapi Application Secrets

| Secret Name | Description | Example/Notes |
|-------------|-------------|---------------|
| `APP_KEYS` | Comma-separated keys for session encryption | Generate with: `openssl rand -base64 32` (repeat 4 times) |
| `API_TOKEN_SALT` | Salt for API token generation | Generate with: `openssl rand -base64 32` |
| `ADMIN_JWT_SECRET` | JWT secret for admin authentication | Generate with: `openssl rand -base64 32` |
| `JWT_SECRET` | JWT secret for user authentication | Generate with: `openssl rand -base64 32` |
| `DATABASE_URL` | Database connection string | `postgresql://user:pass@host:5432/dbname` |

#### 2. Deployment Target Configuration

| Secret Name | Description | Allowed Values |
|-------------|-------------|----------------|
| `DEPLOY_TARGET` | Specifies deployment destination | `docker` or `ec2` |

### Docker Hub Deployment Secrets

Required when `DEPLOY_TARGET=docker`:

| Secret Name | Description | How to Obtain |
|-------------|-------------|---------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | Your Docker Hub account username |
| `DOCKERHUB_TOKEN` | Docker Hub access token | [Create at Docker Hub](https://hub.docker.com/settings/security) → New Access Token |

### AWS EC2 Deployment Secrets

Required when `DEPLOY_TARGET=ec2`:

| Secret Name | Description | How to Obtain |
|-------------|-------------|---------------|
| `SSH_HOST` | EC2 instance IP or domain | AWS Console → EC2 → Your Instance → Public IPv4 |
| `SSH_USER` | SSH user for EC2 access | Usually `ubuntu`, `ec2-user`, or `admin` |
| `SSH_KEY` | Private SSH key for authentication | Your EC2 key pair private key (entire content) |

## Step-by-Step Setup

### Step 1: Generate Strapi Secrets

Run these commands to generate secure random secrets:

```bash
# Generate APP_KEYS (4 keys separated by commas)
echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)"

# Generate API_TOKEN_SALT
echo "API_TOKEN_SALT=$(openssl rand -base64 32)"

# Generate ADMIN_JWT_SECRET
echo "ADMIN_JWT_SECRET=$(openssl rand -base64 32)"

# Generate JWT_SECRET
echo "JWT_SECRET=$(openssl rand -base64 32)"
```

### Step 2: Configure GitHub Secrets

1. Navigate to your repository on GitHub
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret from the tables above

### Step 3: Choose Deployment Strategy

#### Option A: Docker Hub Deployment

1. Create a Docker Hub account at https://hub.docker.com
2. Generate an access token:
   - Go to Account Settings → Security → New Access Token
   - Name: `github-actions-strapi`
   - Permissions: Read, Write, Delete
3. Add to GitHub secrets:
   - `DEPLOY_TARGET` = `docker`
   - `DOCKERHUB_USERNAME` = Your Docker Hub username
   - `DOCKERHUB_TOKEN` = The token you just created

#### Option B: AWS EC2 Deployment

1. Launch an EC2 instance (Ubuntu 20.04 or later recommended)
2. Configure security groups:
   - Allow SSH (port 22) from GitHub Actions IPs
   - Allow HTTP/HTTPS (ports 80/443) for your application
   - Allow port 1337 for Strapi
3. Install required software on EC2:

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2

# Create application directory
sudo mkdir -p /opt/strapi
sudo chown -R ubuntu:ubuntu /opt/strapi

# Create environment file
sudo nano /opt/strapi/.env
# Add your production environment variables
```

4. Add to GitHub secrets:
   - `DEPLOY_TARGET` = `ec2`
   - `SSH_HOST` = Your EC2 public IP or domain
   - `SSH_USER` = `ubuntu` (or your EC2 user)
   - `SSH_KEY` = Your private key content (entire `.pem` file)

### Step 4: Configure Database

For production, use a managed database service:

**PostgreSQL Options:**
- AWS RDS PostgreSQL
- DigitalOcean Managed Database
- Heroku PostgreSQL
- Supabase

Set `DATABASE_URL` secret to your connection string:
```
postgresql://username:password@host:5432/database_name
```

### Step 5: Test the Pipeline

1. Commit and push changes to a feature branch:
```bash
git checkout -b feature/test-ci
git add .
git commit -m "test: validate CI pipeline"
git push origin feature/test-ci
```

2. Create a Pull Request to `main` branch
3. Verify CI job runs and passes
4. Merge PR to `main` branch
5. Verify deployment job runs based on your `DEPLOY_TARGET`

## Pipeline Features

### Continuous Integration (CI)

✅ **Automatic Triggers**: Runs on push and pull requests to main/master
✅ **Dependency Caching**: Speeds up builds with npm cache
✅ **Type Checking**: Validates TypeScript code
✅ **Linting**: Runs ESLint if configured
✅ **Testing**: Executes tests if available
✅ **Build Validation**: Compiles Strapi admin panel
✅ **Artifact Storage**: Saves build outputs for deployment

### Continuous Deployment (CD)

#### Docker Hub Deployment
✅ **Multi-stage Dockerfile**: Optimized production images
✅ **Layer Caching**: Faster subsequent builds
✅ **Automatic Tagging**: SHA, branch, and latest tags
✅ **Security**: Non-root container user
✅ **Health Checks**: Built-in container health monitoring

#### EC2 Deployment
✅ **Zero-downtime**: Uses PM2 for graceful restarts
✅ **Efficient Transfers**: rsync for fast file synchronization
✅ **Health Checks**: Validates application after deployment
✅ **Automatic Restarts**: Handles process management
✅ **Rollback Capability**: Previous version retained

## Monitoring and Debugging

### View Workflow Runs

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select a workflow run to view details
4. Click on job names to see step-by-step logs

### Common Issues and Solutions

#### Issue: CI fails during npm ci
**Solution**: Delete `package-lock.json` and run `npm install` locally to regenerate

#### Issue: Docker build fails
**Solution**: Check Dockerfile paths match your project structure. Ensure `y/` directory exists.

#### Issue: EC2 deployment fails on health check
**Solutions**:
- Verify Strapi is configured to listen on 0.0.0.0:1337
- Check EC2 security groups allow port 1337
- Ensure `.env` file exists on EC2 with proper configuration
- Check PM2 logs: `pm2 logs strapi`

#### Issue: "secrets not found" error
**Solution**: Verify all required secrets are added to GitHub repository settings

### Viewing Deployment Status

After deployment, check the **Actions** tab for:
- ✅ Green checkmarks indicate success
- ❌ Red X indicates failure
- 🟡 Yellow dot indicates in progress

Click on any job to see detailed logs and summaries.

## Production Recommendations

### Security Best Practices

1. **Rotate Secrets Regularly**: Update JWT secrets and API tokens periodically
2. **Use Environment-Specific Secrets**: Separate staging and production secrets
3. **Enable Branch Protection**: Require PR reviews before merging to main
4. **Enable Dependabot**: Automate dependency updates and security patches
5. **Scan Docker Images**: Use tools like Trivy or Snyk for vulnerability scanning

### Performance Optimization

1. **Database Connection Pooling**: Configure proper pool sizes in `config/database.ts`
2. **CDN for Assets**: Use CloudFront or Cloudflare for static assets
3. **Enable Caching**: Implement Redis for session and response caching
4. **Monitoring**: Set up logging with DataDog, New Relic, or CloudWatch

### Scaling Strategies

1. **Horizontal Scaling**: Use Docker Swarm or Kubernetes for multiple instances
2. **Load Balancing**: Place ALB/NLB in front of EC2 instances
3. **Database Replication**: Use read replicas for heavy read workloads
4. **File Storage**: Move uploads to S3/Cloudflare R2

## Additional Resources

- [Strapi Deployment Documentation](https://docs.strapi.io/dev-docs/deployment)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

## Support and Troubleshooting

For issues specific to this CI/CD setup:
1. Check workflow logs in GitHub Actions tab
2. Verify all secrets are correctly configured
3. Test Docker builds locally: `docker build -t strapi-test .`
4. Test EC2 connections: `ssh -i key.pem user@host`

For Strapi-specific issues:
- [Strapi Discord](https://discord.strapi.io/)
- [Strapi Forum](https://forum.strapi.io/)
- [Strapi GitHub Issues](https://github.com/strapi/strapi/issues)

---

**Last Updated**: 2025-10-14
**Pipeline Version**: 1.0.0
**Compatible with**: Strapi v5.24.1
