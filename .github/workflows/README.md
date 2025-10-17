# GitHub Actions Workflows

This directory contains GitHub Actions workflows for continuous integration and deployment.

## Workflows

### CI/CD Pipeline (`ci-cd.yml`)

Complete CI/CD pipeline for Strapi application with support for Docker Hub and AWS EC2 deployments.

#### Status Badge

Add this badge to your repository README.md:

```markdown
![CI/CD Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci-cd.yml/badge.svg)
```

Replace `YOUR_USERNAME` and `YOUR_REPO` with your actual GitHub username and repository name.

#### Workflow Triggers

- **Push**: Runs on push to `main` or `master` branch
- **Pull Request**: Runs on PRs targeting `main` or `master` branch

#### Jobs

1. **CI (Continuous Integration)**
   - Node.js setup with caching
   - Dependency installation
   - TypeScript type checking
   - ESLint (if configured)
   - Test execution (if available)
   - Strapi admin build
   - Build artifact upload

2. **Deploy Docker** (conditional)
   - Runs only if CI passes and `DEPLOY_TARGET=docker`
   - Builds multi-stage Docker image
   - Pushes to Docker Hub with tags
   - Implements layer caching for performance

3. **Deploy EC2** (conditional)
   - Runs only if CI passes and `DEPLOY_TARGET=ec2`
   - Deploys via SSH to EC2 instance
   - Syncs files with rsync
   - Restarts application with PM2
   - Performs health checks

4. **Deployment Status**
   - Generates final report
   - Provides workflow summary

## Configuration

See [CICD_SETUP.md](../CICD_SETUP.md) for detailed setup instructions.

## Quick Setup Checklist

- [ ] Add all required GitHub secrets
- [ ] Set `DEPLOY_TARGET` to `docker` or `ec2`
- [ ] Configure Docker Hub credentials (if using Docker)
- [ ] Configure EC2 SSH access (if using EC2)
- [ ] Set up production database
- [ ] Test with a feature branch first
- [ ] Merge to main to trigger deployment

## Local Testing

### Test Docker Build
```bash
docker build -t strapi-test -f ../../../Dockerfile ../../..
docker run -p 1337:1337 --env-file .env strapi-test
```

### Test Build Process
```bash
npm ci
npm run build
```

## Monitoring

View workflow runs:
1. Go to repository **Actions** tab
2. Select **Strapi CI/CD Pipeline**
3. Click on any run to view details

## Maintenance

### Updating Node.js Version
Edit `ci-cd.yml` and update the `NODE_VERSION` environment variable:
```yaml
env:
  NODE_VERSION: '20.x'  # Change to desired version
```

### Adding Environment Variables
Add new secrets in GitHub repository settings, then reference them in the workflow:
```yaml
env:
  NEW_VAR: ${{ secrets.NEW_VAR }}
```

## Troubleshooting

Common issues and solutions are documented in [CICD_SETUP.md](../CICD_SETUP.md#monitoring-and-debugging).

For workflow-specific issues:
- Check action logs for detailed error messages
- Verify secret names match exactly
- Ensure branch protection rules allow actions
- Check GitHub Actions permissions in repository settings
