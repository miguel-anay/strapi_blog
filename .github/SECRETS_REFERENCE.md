# Referencia Rápida: GitHub Secrets

## 🔑 Lista Completa de Secrets Necesarios

### Para Deployment en EC2 con Docker Compose

| Secret | Descripción | Cómo Generarlo | Ejemplo |
|--------|-------------|----------------|---------|
| **APP_KEYS** | 4 claves de seguridad separadas por comas | `openssl rand -base64 32` (4 veces) | `abc123==,def456==,ghi789==,jkl012==` |
| **API_TOKEN_SALT** | Salt para tokens API | `openssl rand -base64 32` | `Xy9ZkL3mN8pQ...` |
| **ADMIN_JWT_SECRET** | Secret para JWT admin | `openssl rand -base64 32` | `Bv2WxC5yT9rE...` |
| **JWT_SECRET** | Secret para JWT general | `openssl rand -base64 32` | `Km4HfD7sP1qA...` |
| **TRANSFER_TOKEN_SALT** | Salt para tokens transfer | `openssl rand -base64 32` | `Np6GjV3xK8wL...` |
| **DATABASE_NAME** | Nombre de la base de datos | Elige uno | `strapi` |
| **DATABASE_USERNAME** | Usuario de PostgreSQL | Elige uno | `strapi` |
| **DATABASE_PASSWORD** | Contraseña de PostgreSQL | `openssl rand -base64 20` | `Aq3Xz9Ym2Kp...` |
| **DEPLOY_TARGET** | Tipo de deployment | Escribe manualmente | `ec2` |
| **SSH_HOST** | IP pública de EC2 | Ve a AWS Console | `3.25.123.45` |
| **SSH_USER** | Usuario SSH de EC2 | Según tu AMI | `ubuntu` o `ec2-user` |
| **SSH_KEY** | Clave privada SSH completa | `cat tu-clave.pem` | `-----BEGIN RSA...` |

---

## 🚀 Generar Todos los Secrets (Copy-Paste)

### Paso 1: Generar Claves de Seguridad

Ejecuta esto en tu terminal (Linux/Mac/WSL/Git Bash):

```bash
# Genera todas las claves de una vez
echo "=== STRAPI SECURITY KEYS ==="
echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)"
echo ""
echo "API_TOKEN_SALT=$(openssl rand -base64 32)"
echo "ADMIN_JWT_SECRET=$(openssl rand -base64 32)"
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "TRANSFER_TOKEN_SALT=$(openssl rand -base64 32)"
echo ""
echo "=== DATABASE ==="
echo "DATABASE_NAME=strapi"
echo "DATABASE_USERNAME=strapi"
echo "DATABASE_PASSWORD=$(openssl rand -base64 20)"
echo ""
echo "=== DEPLOYMENT ==="
echo "DEPLOY_TARGET=ec2"
echo "SSH_HOST=TU_IP_PUBLICA_EC2"
echo "SSH_USER=ubuntu"
echo "SSH_KEY=CONTENIDO_DE_TU_ARCHIVO_PEM"
```

### Paso 2: Copiar SSH Key

```bash
# En Windows (Git Bash)
cat tu-clave.pem | clip

# En Mac
cat tu-clave.pem | pbcopy

# En Linux
cat tu-clave.pem | xclip -selection clipboard

# Manualmente (cualquier SO)
cat tu-clave.pem
# Selecciona y copia TODO el contenido (incluyendo -----BEGIN/END-----)
```

---

## 📋 Agregar Secrets a GitHub (Paso a Paso)

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (⚙️)
3. En el menú lateral, click en **Secrets and variables** → **Actions**
4. Click en **New repository secret** (botón verde)
5. Agrega cada secret uno por uno:

### Secret #1: APP_KEYS
- **Name**: `APP_KEYS`
- **Value**: Las 4 claves separadas por comas (SIN espacios)
  ```
  Xy9ZkL3mN8pQ==,Bv2WxC5yT9rE==,Km4HfD7sP1qA==,Np6GjV3xK8wL==
  ```

### Secret #2: API_TOKEN_SALT
- **Name**: `API_TOKEN_SALT`
- **Value**: La clave generada con openssl

### Secret #3: ADMIN_JWT_SECRET
- **Name**: `ADMIN_JWT_SECRET`
- **Value**: La clave generada con openssl

### Secret #4: JWT_SECRET
- **Name**: `JWT_SECRET`
- **Value**: La clave generada con openssl

### Secret #5: TRANSFER_TOKEN_SALT
- **Name**: `TRANSFER_TOKEN_SALT`
- **Value**: La clave generada con openssl

### Secret #6: DATABASE_NAME
- **Name**: `DATABASE_NAME`
- **Value**: `strapi` (o el nombre que prefieras)

### Secret #7: DATABASE_USERNAME
- **Name**: `DATABASE_USERNAME`
- **Value**: `strapi` (o el usuario que prefieras)

### Secret #8: DATABASE_PASSWORD
- **Name**: `DATABASE_PASSWORD`
- **Value**: Una contraseña segura generada

### Secret #9: DEPLOY_TARGET
- **Name**: `DEPLOY_TARGET`
- **Value**: `ec2` (exactamente así, en minúsculas)

### Secret #10: SSH_HOST
- **Name**: `SSH_HOST`
- **Value**: Tu IP pública de EC2 (ejemplo: `3.25.123.45`)

### Secret #11: SSH_USER
- **Name**: `SSH_USER`
- **Value**:
  - `ubuntu` (si usas Ubuntu)
  - `ec2-user` (si usas Amazon Linux 2)

### Secret #12: SSH_KEY
- **Name**: `SSH_KEY`
- **Value**: Contenido COMPLETO de tu archivo `.pem`
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA... (muchas líneas)
  ...
  -----END RSA PRIVATE KEY-----
  ```

---

## ✅ Verificación

Después de agregar todos los secrets, deberías ver esto en GitHub:

```
Repository secrets (12)
├── APP_KEYS                 (Set 1 minute ago)
├── API_TOKEN_SALT           (Set 1 minute ago)
├── ADMIN_JWT_SECRET         (Set 1 minute ago)
├── JWT_SECRET               (Set 1 minute ago)
├── TRANSFER_TOKEN_SALT      (Set 1 minute ago)
├── DATABASE_NAME            (Set 1 minute ago)
├── DATABASE_USERNAME        (Set 1 minute ago)
├── DATABASE_PASSWORD        (Set 1 minute ago)
├── DEPLOY_TARGET            (Set 1 minute ago)
├── SSH_HOST                 (Set 1 minute ago)
├── SSH_USER                 (Set 1 minute ago)
└── SSH_KEY                  (Set 1 minute ago)
```

---

## 🔒 ¿Dónde van estas Variables?

### En el Pipeline (GitHub Actions)
Los secrets se usan en `.github/workflows/ci-cd.yml` para:
1. Crear el archivo `.env` automáticamente en el servidor
2. Conectarse por SSH al EC2
3. Configurar las variables de entorno de Docker Compose

### En el Servidor (EC2)
El pipeline crea automáticamente el archivo `/opt/strapi/.env`:

```env
# Server Configuration
HOST=0.0.0.0
PORT=1337

# Security Keys (desde GitHub Secrets)
APP_KEYS=<valor de GitHub Secret>
API_TOKEN_SALT=<valor de GitHub Secret>
ADMIN_JWT_SECRET=<valor de GitHub Secret>
JWT_SECRET=<valor de GitHub Secret>
TRANSFER_TOKEN_SALT=<valor de GitHub Secret>

# Database Configuration (PostgreSQL en Docker)
DATABASE_CLIENT=postgres
DATABASE_HOST=strapiDB
DATABASE_PORT=5432
DATABASE_NAME=<valor de GitHub Secret>
DATABASE_USERNAME=<valor de GitHub Secret>
DATABASE_PASSWORD=<valor de GitHub Secret>
DATABASE_SSL=false

# Environment
NODE_ENV=production
```

### En Docker Compose
El `docker-compose.yml` lee el `.env` automáticamente:

```yaml
services:
  strapi:
    env_file: .env
    environment:
      DATABASE_CLIENT: ${DATABASE_CLIENT}
      DATABASE_HOST: strapiDB
      # ... etc
```

---

## 🛡️ Seguridad

### ✅ Buenas Prácticas

1. **NUNCA subas el `.env` a Git**
   - Ya está en `.gitignore`
   - El pipeline lo crea automáticamente

2. **Rota los secrets cada 3-6 meses**
   - Genera nuevos valores
   - Actualiza en GitHub Secrets
   - Redeploy automático

3. **No compartas los secrets**
   - Solo están en GitHub (encriptados)
   - Solo aparecen en el servidor (permisos 600)

4. **Usa contraseñas fuertes**
   - Mínimo 20 caracteres
   - Usa el generador: `openssl rand -base64 32`

### ❌ NO Hacer

1. ❌ NO hardcodees secrets en el código
2. ❌ NO commits el archivo `.env`
3. ❌ NO uses contraseñas débiles tipo `password123`
4. ❌ NO compartas las claves por email/Slack/chat
5. ❌ NO uses los mismos secrets en prod y dev

---

## 🔄 Actualizar Secrets

Si necesitas cambiar algún secret:

1. **En GitHub**:
   - Settings → Secrets → Actions
   - Click en el secret que quieres cambiar
   - Click en **Update**
   - Ingresa el nuevo valor
   - Click en **Update secret**

2. **Redeploy**:
   ```bash
   # Haz un push a main para activar el deployment
   git commit --allow-empty -m "chore: update secrets"
   git push origin main

   # O manualmente en el servidor:
   ssh -i tu-clave.pem ubuntu@TU_IP_EC2
   cd /opt/strapi

   # Edita el .env con los nuevos valores
   nano .env

   # Reinicia los contenedores
   docker-compose restart
   ```

---

## 🧪 Probar Variables Localmente

Para probar el proyecto localmente antes de deployment:

```bash
# 1. Crea .env en la raíz del proyecto
cp .env.example .env  # Si existe
# O crea uno nuevo:
nano .env

# 2. Pega los valores generados
# (los mismos que agregaste a GitHub Secrets)

# 3. Levanta con Docker Compose localmente
docker-compose up -d

# 4. Accede a http://localhost:1337
```

---

## 📞 Troubleshooting

### "Secret not found"
- Verifica el nombre exacto (case-sensitive)
- `APP_KEYS` ≠ `app_keys` ≠ `App_Keys`

### "Invalid base64"
- Asegúrate de copiar el valor completo
- No incluyas espacios al inicio/final
- Para SSH_KEY, incluye las líneas BEGIN/END

### "Database connection failed"
- Verifica `DATABASE_NAME`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`
- Deben ser exactamente iguales en:
  - GitHub Secrets
  - docker-compose.yml
  - El pipeline crea el .env automáticamente

### "SSH connection refused"
- Verifica `SSH_HOST` (IP pública correcta)
- Verifica `SSH_USER` (ubuntu vs ec2-user)
- Verifica `SSH_KEY` (contenido completo del .pem)
- Security Group debe tener puerto 22 abierto

---

## 🎓 Recursos Adicionales

- [Guía Completa de Deployment](./EC2_DOCKER_COMPOSE_GUIDE.md)
- [Quick Reference](./QUICK_REFERENCE.md)
- [Workflow Documentation](./workflows/README.md)
- [Strapi Environment Variables](https://docs.strapi.io/dev-docs/configurations/environment)

---

**Última actualización**: 2025-10-14
**Versión**: 1.0.0
