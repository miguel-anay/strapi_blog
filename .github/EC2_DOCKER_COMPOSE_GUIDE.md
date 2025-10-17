# Guía Completa: Deploy Automático con Docker Compose en EC2

Esta guía explica cómo configurar el deployment automático de tu proyecto Strapi + PostgreSQL usando Docker Compose en AWS EC2.

## 📋 Tabla de Contenidos

1. [¿Qué hace el Pipeline?](#qué-hace-el-pipeline)
2. [Requisitos Previos](#requisitos-previos)
3. [Configuración en AWS EC2](#configuración-en-aws-ec2)
4. [Configuración en GitHub](#configuración-en-github)
5. [Primer Deployment](#primer-deployment)
6. [Gestión Post-Deployment](#gestión-post-deployment)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 ¿Qué hace el Pipeline?

El pipeline de GitHub Actions hace TODO por ti:

1. **Clona el repositorio** completo en tu servidor EC2 (en `/opt/strapi/`)
2. **Crea el archivo `.env`** automáticamente desde tus GitHub Secrets
3. **Instala Docker y Docker Compose** (si no están instalados)
4. **Ejecuta `docker-compose up -d --build`** para levantar:
   - 🐳 Contenedor de Strapi (puerto 1337)
   - 🐘 Contenedor de PostgreSQL (puerto 5432)
5. **Verifica que todo funcione** con health checks automáticos

### Variables de Entorno

**NO necesitas crear manualmente el `.env`** - el pipeline lo crea automáticamente desde los GitHub Secrets.

---

## 📦 Requisitos Previos

### 1. Servidor EC2 con:
- **Sistema Operativo**: Ubuntu 20.04/22.04 o Amazon Linux 2
- **Instancia mínima**: t2.small (2GB RAM)
- **Instancia recomendada**: t2.medium (4GB RAM) o superior
- **Almacenamiento**: 20GB mínimo
- **Security Group** con puertos abiertos:
  - Puerto **22** (SSH)
  - Puerto **1337** (Strapi)
  - Puerto **5432** (PostgreSQL - opcional, solo si necesitas acceso externo)

### 2. Acceso SSH configurado:
- Archivo `.pem` de tu instancia EC2
- Usuario por defecto: `ubuntu` (Ubuntu) o `ec2-user` (Amazon Linux)

---

## 🚀 Configuración en AWS EC2

### Paso 1: Conectarse al EC2

```bash
# Asigna permisos correctos a tu clave SSH
chmod 400 tu-clave.pem

# Conéctate a tu EC2
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA
```

### Paso 2: Crear el Directorio de Deployment

```bash
# Crear directorio para Strapi
sudo mkdir -p /opt/strapi

# Dar permisos al usuario actual
sudo chown -R $USER:$USER /opt/strapi

# Verificar
ls -la /opt/
```

### Paso 3: Instalar Dependencias Básicas (Opcional)

El pipeline instala Docker automáticamente, pero puedes hacerlo manualmente:

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar utilidades básicas
sudo apt install -y curl git htop

# Instalar Docker (el pipeline lo hace automáticamente si no existe)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose (el pipeline lo hace automáticamente si no existe)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalación
docker --version
docker-compose --version

# IMPORTANTE: Salir y volver a conectar para aplicar permisos
exit
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA
```

---

## 🔐 Configuración en GitHub

### Paso 1: Generar Secrets para Strapi

```bash
# En tu máquina local, genera las claves:

# APP_KEYS (4 claves separadas por comas)
echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)"

# Otros secrets
echo "API_TOKEN_SALT=$(openssl rand -base64 32)"
echo "ADMIN_JWT_SECRET=$(openssl rand -base64 32)"
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "TRANSFER_TOKEN_SALT=$(openssl rand -base64 32)"
```

### Paso 2: Agregar Secrets a GitHub

Ve a tu repositorio en GitHub:

**Settings → Secrets and variables → Actions → New repository secret**

Agrega los siguientes secrets uno por uno:

#### Secrets de Strapi (Obligatorios)
```yaml
APP_KEYS
# Valor: las 4 claves generadas, separadas por comas (SIN espacios)
# Ejemplo: abc123==,def456==,ghi789==,jkl012==

API_TOKEN_SALT
# Valor: clave generada con openssl

ADMIN_JWT_SECRET
# Valor: clave generada con openssl

JWT_SECRET
# Valor: clave generada con openssl

TRANSFER_TOKEN_SALT
# Valor: clave generada con openssl
```

#### Secrets de Base de Datos (Obligatorios)
```yaml
DATABASE_NAME
# Valor: strapi (o el nombre que prefieras)

DATABASE_USERNAME
# Valor: strapi (o el usuario que prefieras)

DATABASE_PASSWORD
# Valor: una contraseña segura (genera con: openssl rand -base64 20)
```

#### Secrets de EC2 (Obligatorios)
```yaml
DEPLOY_TARGET
# Valor: ec2
# (este valor indica al pipeline que use EC2 en lugar de Docker Hub)

SSH_HOST
# Valor: TU_IP_PUBLICA_EC2
# Ejemplo: 3.25.123.45

SSH_USER
# Valor: ubuntu (para Ubuntu) o ec2-user (para Amazon Linux)

SSH_KEY
# Valor: Contenido COMPLETO de tu archivo .pem
# Cómo obtenerlo:
#   En Windows: cat tu-clave.pem | clip
#   En Mac/Linux: cat tu-clave.pem | pbcopy
# Pega TODO el contenido, incluyendo:
# -----BEGIN RSA PRIVATE KEY-----
# ... líneas de la clave ...
# -----END RSA PRIVATE KEY-----
```

### Verificación de Secrets

Deberías tener **11 secrets** en total:

1. ✅ APP_KEYS
2. ✅ API_TOKEN_SALT
3. ✅ ADMIN_JWT_SECRET
4. ✅ JWT_SECRET
5. ✅ TRANSFER_TOKEN_SALT
6. ✅ DATABASE_NAME
7. ✅ DATABASE_USERNAME
8. ✅ DATABASE_PASSWORD
9. ✅ DEPLOY_TARGET
10. ✅ SSH_HOST
11. ✅ SSH_USER
12. ✅ SSH_KEY

---

## 🎬 Primer Deployment

### Opción 1: Deployment desde Pull Request (Recomendado)

```bash
# 1. Crear rama de feature
git checkout -b feature/initial-deployment

# 2. Agregar los archivos del CI/CD (si aún no lo hiciste)
git add .github/workflows/ci-cd.yml
git add docker-compose.yml
git add Dockerfile
git add .dockerignore

# 3. Commit
git commit -m "ci: add Docker Compose deployment for EC2"

# 4. Push
git push origin feature/initial-deployment

# 5. Crear Pull Request en GitHub
# - Ve a tu repositorio en GitHub
# - Click en "Pull requests" → "New pull request"
# - Selecciona tu rama feature/initial-deployment
# - Crea el PR

# 6. Esperar que el CI pase (2-5 minutos)
# - Ve a la pestaña "Actions" en GitHub
# - Verás el workflow ejecutándose
# - Solo se ejecuta el CI (no el deployment aún)

# 7. Merge a main/master
# - Una vez que el CI pase ✅
# - Haz merge del Pull Request
# - Esto activará el deployment automático a EC2
```

### Opción 2: Deployment Directo a Main

```bash
# Solo si estás seguro y quieres deployment inmediato

git checkout main
git add .
git commit -m "ci: add Docker Compose deployment for EC2"
git push origin main

# Esto activará inmediatamente:
# 1. CI Job (2-5 min)
# 2. EC2 Deployment Job (5-10 min)
```

### Monitorear el Deployment

1. Ve a **GitHub → Actions** tab
2. Click en el workflow que está corriendo
3. Verás 3 jobs:
   - ✅ **CI** (Continuous Integration)
   - ⏳ **Deploy to AWS EC2 (Docker Compose)** ← Este es el importante
   - ⏭️ **Deployment Status Report**

4. Click en "Deploy to AWS EC2" para ver logs en tiempo real:
   ```
   Sync Project to EC2 ✅
   Create Environment File ✅
   Install Docker Dependencies ✅
   Deploy with Docker Compose ✅
   Health Check ✅
   ```

### ¿Cuánto tarda?

- **Primera vez**: 8-12 minutos
  - CI: 3-5 min
  - Instalar Docker: 2-3 min
  - Build de imágenes: 3-5 min
  - Health checks: 1-2 min

- **Deployments posteriores**: 5-8 minutos
  - CI: 2 min (con caché)
  - Deployment: 3-5 min
  - Health checks: 1 min

---

## 🎮 Gestión Post-Deployment

### Acceder a tu Aplicación

Una vez completado el deployment:

```bash
# URL de la aplicación
http://TU_IP_PUBLICA:1337

# Panel de administración de Strapi
http://TU_IP_PUBLICA:1337/admin
```

**IMPORTANTE**: La primera vez que accedas a `/admin`, Strapi te pedirá crear el usuario administrador.

### Conectarse al Servidor

```bash
# SSH al servidor
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA

# Ir al directorio del proyecto
cd /opt/strapi
```

### Comandos Útiles en el Servidor

```bash
# Ver estado de los contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs solo de Strapi
docker-compose logs -f strapi

# Ver logs solo de PostgreSQL
docker-compose logs -f strapiDB

# Reiniciar servicios
docker-compose restart

# Parar servicios
docker-compose down

# Levantar servicios
docker-compose up -d

# Rebuild completo (útil después de cambios en Dockerfile)
docker-compose up -d --build --force-recreate

# Entrar al contenedor de Strapi
docker exec -it strapi sh

# Entrar al contenedor de PostgreSQL
docker exec -it strapiDB psql -U strapi -d strapi

# Ver uso de recursos
docker stats

# Limpiar imágenes antiguas (libera espacio)
docker system prune -a
```

### Ver Variables de Entorno

```bash
# El archivo .env está en /opt/strapi/.env
cat /opt/strapi/.env

# NUNCA compartas este archivo - contiene secrets
```

### Backup de Base de Datos

```bash
# Crear backup
docker exec strapiDB pg_dump -U strapi strapi > backup-$(date +%Y%m%d).sql

# Restaurar backup
cat backup-20250314.sql | docker exec -i strapiDB psql -U strapi -d strapi
```

---

## 🔧 Troubleshooting

### Problema 1: Health Check Falla

**Síntomas**: El deployment falla en el paso "Health Check"

**Solución**:
```bash
# Conéctate al servidor
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA
cd /opt/strapi

# Ver logs de Strapi
docker-compose logs strapi

# Buscar errores comunes:
# - "Database connection error" → Verifica DATABASE_PASSWORD en GitHub Secrets
# - "APP_KEYS is required" → Verifica APP_KEYS en GitHub Secrets
# - "Port 1337 already in use" → Puerto ocupado, reinicia: docker-compose restart
```

### Problema 2: Contenedores No Inician

**Síntomas**: `docker ps` no muestra los contenedores

**Solución**:
```bash
cd /opt/strapi

# Ver qué falló
docker-compose logs

# Reiniciar desde cero
docker-compose down
docker-compose up -d

# Si sigue fallando, rebuild completo
docker-compose down -v  # ⚠️ CUIDADO: Esto borra los datos
docker-compose up -d --build
```

### Problema 3: No Puedo Acceder a la Aplicación

**Síntomas**: `http://TU_IP:1337` no responde

**Checklist**:
```bash
# 1. ¿El contenedor está corriendo?
docker ps | grep strapi
# Debe aparecer "strapi" con estado "Up"

# 2. ¿El puerto 1337 está abierto en el Security Group de EC2?
# Ve a AWS Console → EC2 → Security Groups
# Agrega regla: Custom TCP, Port 1337, Source: 0.0.0.0/0

# 3. ¿Strapi está escuchando?
curl http://localhost:1337/_health
# Desde dentro del servidor debe responder: {"status":"ok"}

# 4. ¿Firewall local bloqueando?
sudo ufw status
# Si está activo, agrega regla: sudo ufw allow 1337
```

### Problema 4: Cambios No se Reflejan

**Síntomas**: Hice push pero la aplicación no cambió

**Solución**:
```bash
# El deployment solo se ejecuta en push a main/master
# Verifica:
# 1. ¿Hiciste merge a main?
git branch  # Debes estar en main

# 2. ¿El CI pasó?
# Ve a GitHub Actions y verifica que el job terminó ✅

# 3. Forzar redeploy manualmente en el servidor:
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA
cd /opt/strapi
git pull origin main
docker-compose up -d --build
```

### Problema 5: "No Space Left on Device"

**Síntomas**: Error de espacio en disco

**Solución**:
```bash
# Ver uso de disco
df -h

# Limpiar imágenes Docker antiguas
docker system prune -a -f

# Limpiar volúmenes no usados
docker volume prune -f

# Limpiar logs
sudo journalctl --vacuum-size=100M

# Si sigue sin espacio, aumenta el EBS volume en AWS Console
```

### Problema 6: Deployment Muy Lento

**Síntomas**: El deployment tarda más de 15 minutos

**Solución**:
```bash
# Verifica recursos del EC2
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA
htop  # Presiona q para salir

# Si la CPU está al 100% o RAM está llena:
# Considera upgrade a instancia más grande (t2.medium → t2.large)

# Optimiza el build de Docker:
# - Verifica que .dockerignore esté correcto
# - Asegúrate de que node_modules no se copie
```

### Problema 7: Admin Panel Pide Crear Usuario Cada Vez

**Síntomas**: Cada deployment borra los usuarios

**Solución**:
```bash
# Verificar que el volumen de PostgreSQL persista
docker volume ls | grep strapi
# Debe aparecer: strapi_strapi-data

# Verificar contenido del volumen
docker exec strapiDB psql -U strapi -d strapi -c "\dt"

# Si las tablas no persisten, el volumen está mal configurado
# Verifica docker-compose.yml:
cat docker-compose.yml | grep -A 5 "volumes:"
# Debe tener: - strapi-data:/var/lib/postgresql/data/
```

---

## 📊 Monitoreo y Logs

### Ver Logs en GitHub Actions

1. Ve a **Actions** tab
2. Click en el workflow run
3. Click en cualquier job para ver logs detallados
4. Los summaries tienen comandos útiles para SSH

### Ver Logs en el Servidor

```bash
# Logs en tiempo real de ambos servicios
docker-compose logs -f

# Solo últimas 100 líneas
docker-compose logs --tail=100

# Logs de las últimas 24h
docker-compose logs --since 24h

# Guardar logs a archivo
docker-compose logs > logs-$(date +%Y%m%d).txt
```

### Métricas de Recursos

```bash
# CPU, RAM, Network en tiempo real
docker stats

# Uso de disco
df -h

# Procesos del sistema
htop
```

---

## 🔄 Workflow de Desarrollo

### Desarrollo Local → Staging → Production

```bash
# 1. Desarrollo local
git checkout -b feature/nueva-funcionalidad
# ... hacer cambios ...
git add .
git commit -m "feat: agregar nueva funcionalidad"
git push origin feature/nueva-funcionalidad

# 2. Crear PR y probar CI
# - El CI se ejecuta automáticamente
# - Verifica que pase antes de merge

# 3. Merge a main (Production)
# - Merge del PR en GitHub
# - Deployment automático a EC2

# 4. Verificar en producción
curl http://TU_IP:1337/_health
```

### Rollback (Volver a Versión Anterior)

```bash
# Si algo sale mal después de un deployment:

# Opción 1: Revert del commit en GitHub
git revert HEAD
git push origin main
# Esto activa un nuevo deployment con el código anterior

# Opción 2: Rollback manual en el servidor
ssh -i tu-clave.pem ubuntu@TU_IP_PUBLICA
cd /opt/strapi
git log --oneline  # Ver commits
git checkout <commit-hash-anterior>
docker-compose up -d --build
```

---

## 🎓 Próximos Pasos

### Optimizaciones Recomendadas

1. **Dominio Personalizado**:
   ```bash
   # Configura un dominio en Route53 (AWS) o Cloudflare
   # Apunta el A record a tu IP de EC2
   # Instala Nginx como reverse proxy
   ```

2. **HTTPS con Let's Encrypt**:
   ```bash
   # Instala Certbot
   sudo apt install certbot python3-certbot-nginx

   # Obtén certificado SSL
   sudo certbot --nginx -d tudominio.com
   ```

3. **Monitoreo Avanzado**:
   - Instala **Portainer** para gestión visual de Docker
   - Configura **Grafana + Prometheus** para métricas
   - Usa **Sentry** para error tracking

4. **Backups Automáticos**:
   ```bash
   # Crea un cron job para backups diarios
   crontab -e
   # Agrega: 0 2 * * * cd /opt/strapi && docker exec strapiDB pg_dump -U strapi strapi > /backups/strapi-$(date +\%Y\%m\%d).sql
   ```

5. **Auto-Scaling**:
   - Configura un Load Balancer (ALB) en AWS
   - Usa Auto Scaling Group
   - Múltiples instancias EC2

---

## 📞 Soporte

### Recursos Útiles

- **Documentación Strapi**: https://docs.strapi.io
- **Docker Docs**: https://docs.docker.com
- **GitHub Actions**: https://docs.github.com/en/actions
- **AWS EC2**: https://docs.aws.amazon.com/ec2

### Logs para Reportar Problemas

Si necesitas ayuda, incluye:

```bash
# 1. Versiones
docker --version
docker-compose --version
node --version

# 2. Estado de contenedores
docker-compose ps

# 3. Logs recientes
docker-compose logs --tail=200

# 4. Variables de entorno (SIN valores sensibles)
cat .env | grep -v "PASSWORD\|SECRET\|KEY"

# 5. Uso de recursos
docker stats --no-stream
df -h
```

---

## ✅ Checklist Final

Antes de considerar tu deployment completo:

- [ ] Todos los GitHub Secrets configurados (11 secrets)
- [ ] Security Group de EC2 con puertos 22 y 1337 abiertos
- [ ] Directorio `/opt/strapi/` creado en EC2
- [ ] Docker y Docker Compose instalados en EC2
- [ ] CI pipeline pasando ✅ en GitHub Actions
- [ ] Deployment exitoso a EC2
- [ ] Health checks pasando
- [ ] Aplicación accesible en `http://TU_IP:1337`
- [ ] Admin panel accesible en `http://TU_IP:1337/admin`
- [ ] Usuario administrador creado en Strapi
- [ ] Base de datos PostgreSQL funcionando
- [ ] Contenedores reiniciándose automáticamente (`restart: unless-stopped`)

---

**¡Felicitaciones!** 🎉 Tu aplicación Strapi está desplegada con CI/CD automático usando Docker Compose en AWS EC2.

---

**Última actualización**: 2025-10-14
**Versión**: 2.0.0 (Docker Compose Edition)
