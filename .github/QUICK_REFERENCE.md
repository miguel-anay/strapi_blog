# CI/CD Quick Reference Card

## 🚀 Getting Started (5 Steps)

### 1️⃣ Generate Secrets
```bash
openssl rand -base64 32  # Run 4 times for APP_KEYS (comma-separated)
openssl rand -base64 32  # API_TOKEN_SALT
openssl rand -base64 32  # ADMIN_JWT_SECRET
openssl rand -base64 32  # JWT_SECRET
```

### 2️⃣ Add to GitHub
**Settings → Secrets and variables → Actions → New repository secret**

Required secrets:
- `APP_KEYS` - 4 keys separated by commas
- `API_TOKEN_SALT` - Random base64 string
- `ADMIN_JWT_SECRET` - Random base64 string
- `JWT_SECRET` - Random base64 string
- `DATABASE_URL` - PostgreSQL connection string
- `DEPLOY_TARGET` - Either `docker` or `ec2`

### 3️⃣ Choose Deployment

**Option A: Docker Hub**
- `DOCKERHUB_USERNAME` - Your username
- `DOCKERHUB_TOKEN` - Access token from hub.docker.com

**Option B: AWS EC2 (Docker Compose)**
- `SSH_HOST` - EC2 IP address
- `SSH_USER` - SSH username (usually `ubuntu`)
- `SSH_KEY` - Private key content (.pem file)
- `DATABASE_NAME` - Database name (e.g., `strapi`)
- `DATABASE_USERNAME` - Database user (e.g., `strapi`)
- `DATABASE_PASSWORD` - Database password (generate secure password)
- `TRANSFER_TOKEN_SALT` - Random base64 string

### 4️⃣ Test CI
```bash
git checkout -b feature/test-ci
git push origin feature/test-ci
# Create PR → Check Actions tab
```

### 5️⃣ Deploy
```bash
# Merge PR to main/master
# Watch Actions tab for deployment
```

## 📊 Pipeline Overview

```
┌─────────────────────┐
│   Push to main      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   CI Job (3-5 min)  │
│   • Install deps    │
│   • Type check      │
│   • Build admin     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Deploy (5-8 min)  │
│   Docker or EC2     │
└─────────────────────┘
```

## 🔧 Common Commands

### Commit with Conventional Format
```bash
git add .
git commit -m "feat(api): add new endpoint"
git push
```

### Test Docker Build Locally
```bash
docker build -t strapi-test -f Dockerfile .
docker run -p 1337:1337 --env-file y/.env strapi-test
```

### View Workflow Status
```bash
# In GitHub repository
# Click "Actions" tab → Select workflow run
```

### Generate All Secrets at Once
```bash
echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)"
echo "API_TOKEN_SALT=$(openssl rand -base64 32)"
echo "ADMIN_JWT_SECRET=$(openssl rand -base64 32)"
echo "JWT_SECRET=$(openssl rand -base64 32)"
```

## ⚡ Commit Types Quick Guide

| Type | Use When | Example |
|------|----------|---------|
| `feat` | New feature | `feat(api): add search` |
| `fix` | Bug fix | `fix(auth): resolve login` |
| `docs` | Documentation | `docs: update README` |
| `chore` | Maintenance | `chore(deps): update strapi` |
| `ci` | CI/CD changes | `ci: add deployment` |
| `refactor` | Code restructure | `refactor(api): simplify` |
| `test` | Tests | `test(api): add unit tests` |
| `perf` | Performance | `perf(db): optimize query` |

## 🐛 Troubleshooting

| Problem | Quick Fix |
|---------|-----------|
| CI fails on install | `npm install && git add package-lock.json` |
| Docker build fails | Check Dockerfile paths |
| EC2 won't connect | Verify SSH_HOST and SSH_KEY |
| Secrets not found | Check exact secret name spelling |
| Deploy not triggered | Ensure DEPLOY_TARGET is set |

## 📁 File Locations

```
C:\strapi\y\
├── .github\
│   ├── workflows\
│   │   ├── ci-cd.yml          ← Main workflow
│   │   └── README.md          ← Workflow docs
│   ├── CICD_SETUP.md          ← Detailed setup guide
│   ├── DEPLOYMENT_SUMMARY.md  ← Complete summary
│   ├── COMMIT_GUIDELINES.md   ← Commit standards
│   └── QUICK_REFERENCE.md     ← This file
│
C:\strapi\
├── Dockerfile                  ← Docker build config
└── .dockerignore              ← Docker ignore rules
```

## 🎯 Status Checks

### ✅ Ready to Deploy When:
- [ ] All GitHub secrets added
- [ ] DEPLOY_TARGET set (docker or ec2)
- [ ] Database configured
- [ ] CI passes on feature branch
- [ ] PR approved and merged

### ⚠️ Warning Signs:
- CI takes >10 minutes → Check cache
- Build fails → Check dependencies
- Deploy fails → Check secrets
- Health check fails → Check config

## 🔗 Quick Links

- [Full Setup Guide](./CICD_SETUP.md)
- [Deployment Summary](./DEPLOYMENT_SUMMARY.md)
- [Commit Guidelines](./COMMIT_GUIDELINES.md)
- [Strapi Deployment Docs](https://docs.strapi.io/dev-docs/deployment)

## 💡 Pro Tips

1. **Test CI first** - Create PR before merging to main
2. **Use feature branches** - Never commit directly to main
3. **Monitor first deploy** - Watch logs in Actions tab
4. **Enable notifications** - Get alerts for failed builds
5. **Keep secrets updated** - Rotate quarterly
6. **Cache everything** - Pipeline already optimized
7. **Use PM2 on EC2** - Already configured in workflow
8. **Tag Docker images** - Automatic with SHA and latest

## 📞 Support

- **Documentation**: Check `.github/` folder files
- **Workflow Issues**: View Actions tab logs
- **Strapi Issues**: https://discord.strapi.io/
- **GitHub Actions**: https://docs.github.com/en/actions

---

**Last Updated**: 2025-10-14
**Version**: 1.0.0
