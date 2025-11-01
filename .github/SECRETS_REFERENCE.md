# Referencia Rápida: GitHub Secrets

## 🔑 Lista Completa de Secrets Necesarios

### Secrets Obligatorios (Docker Hub)

| Secret | Descripción | Cómo Generarlo | Ejemplo |
|--------|-------------|----------------|---------|
| **DOCKERHUB_USERNAME** | Tu usuario de Docker Hub | Regístrate en hub.docker.com | `k3n5h1n` |
| **DOCKERHUB_TOKEN** | Token de acceso de Docker Hub | Account Settings → Security → New Access Token | `dckr_pat_abc123...` |
| **APP_KEYS** | 4 claves de seguridad separadas por comas | `openssl rand -base64 32` (4 veces) | `abc123==,def456==,ghi789==,jkl012==` |
| **API_TOKEN_SALT** | Salt para tokens API | `openssl rand -base64 32` | `Xy9ZkL3mN8pQ...` |
| **ADMIN_JWT_SECRET** | Secret para JWT admin | `openssl rand -base64 32` | `Bv2WxC5yT9rE...` |
| **JWT_SECRET** | Secret para JWT general | `openssl rand -base64 32` | `Km4HfD7sP1qA...` |
| **TRANSFER_TOKEN_SALT** | Salt para tokens transfer | `openssl rand -base64 32` | `Np6GjV3xK8wL...` |

### Secrets Opcionales (Solo para Deploy a EC2 en Producción)

| Secret | Descripción | Cómo Generarlo | Ejemplo |
|--------|-------------|----------------|---------|
| **DATABASE_NAME** | Nombre de la base de datos PostgreSQL | Elige uno | `strapi` |
| **DATABASE_USERNAME** | Usuario de PostgreSQL | Elige uno | `strapi` |
| **DATABASE_PASSWORD** | Contraseña de PostgreSQL | `openssl rand -base64 20` | `Aq3Xz9Ym2Kp...` |
| **SSH_HOST** | IP pública de EC2 | Ve a AWS Console | `3.25.123.45` |
| **SSH_USER** | Usuario SSH de EC2 | Según tu AMI | `ubuntu` o `ec2-user` |
| **SSH_KEY** | Clave privada SSH completa | `cat tu-clave.pem` | `-----BEGIN RSA...` |

---

## 🔄 Flujo CI/CD

### Push a main/master:
1. ✅ **CI**: Tests y build del proyecto
2. ✅ **Docker Hub**: Siempre publica la imagen `k3n5h1n/strapi-blog:latest`
3. 🔀 **EC2**: Solo si están configurados los secrets SSH (`SSH_KEY`, `SSH_HOST`, `SSH_USER`)

### Push a otras ramas:
1. ✅ **CI**: Tests y build del proyecto
2. ❌ No publica a Docker Hub
3. ❌ No hace deploy a EC2

---

## 🚀 Generar Todos los Secrets (Copy-Paste)

### Paso 1: Generar Claves de Seguridad

Ejecuta esto en tu terminal (Linux/Mac/WSL/Git Bash):

```bash
# Genera todas las claves de una vez
echo "=== DOCKER HUB (OBLIGATORIO) ==="
echo "DOCKERHUB_USERNAME=k3n5h1n"
echo "DOCKERHUB_TOKEN=VE_A_DOCKER_HUB_PARA_GENERAR_TOKEN"
echo ""
echo "=== STRAPI SECURITY KEYS (OBLIGATORIO) ==="
echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)"
echo ""
echo "API_TOKEN_SALT=$(openssl rand -base64 32)"
echo "ADMIN_JWT_SECRET=$(openssl rand -base64 32)"
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "TRANSFER_TOKEN_SALT=$(openssl rand -base64 32)"
echo ""
echo "=== EC2 DEPLOYMENT (OPCIONAL - Solo para producción) ==="
echo "DATABASE_NAME=strapi"
echo "DATABASE_USERNAME=strapi"
echo "DATABASE_PASSWORD=$(openssl rand -base64 20)"
echo "SSH_HOST=TU_IP_PUBLICA_EC2"
echo "SSH_USER=ubuntu"
echo "SSH_KEY=CONTENIDO_DE_TU_ARCHIVO_PEM"
```

### Cómo obtener DOCKERHUB_TOKEN:

1. Ve a [Docker Hub](https://hub.docker.com)
2. Login → Account Settings → Security
3. Click en **New Access Token**
4. Access Token Description: `GitHub Actions CI/CD`
5. Access permissions: **Read, Write, Delete**
6. Click **Generate**
7. Copia el token (solo se muestra una vez)
8. Guárdalo en GitHub Secrets como `DOCKERHUB_TOKEN`

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

### Secret #1: DOCKERHUB_USERNAME
- **Name**: `DOCKERHUB_USERNAME`
- **Value**: Tu usuario de Docker Hub (ejemplo: `k3n5h1n`)

### Secret #2: DOCKERHUB_TOKEN
- **Name**: `DOCKERHUB_TOKEN`
- **Value**: El token generado en Docker Hub
  ```
  dckr_pat_aBcDeFgHiJkLmNoPqRsTuVwXyZ123456
  ```

### Secret #3: APP_KEYS
- **Name**: `APP_KEYS`
- **Value**: Las 4 claves separadas por comas (SIN espacios)
  ```
  Xy9ZkL3mN8pQ==,Bv2WxC5yT9rE==,Km4HfD7sP1qA==,Np6GjV3xK8wL==
  ```

### Secret #4: API_TOKEN_SALT
- **Name**: `API_TOKEN_SALT`
- **Value**: La clave generada con openssl

### Secret #5: ADMIN_JWT_SECRET
- **Name**: `ADMIN_JWT_SECRET`
- **Value**: La clave generada con openssl

### Secret #6: JWT_SECRET
- **Name**: `JWT_SECRET`
- **Value**: La clave generada con openssl

### Secret #7: TRANSFER_TOKEN_SALT
- **Name**: `TRANSFER_TOKEN_SALT`
- **Value**: La clave generada con openssl

---

## Secrets Opcionales (Solo si despliegas a EC2)

### Secret #8: DATABASE_NAME
- **Name**: `DATABASE_NAME`
- **Value**: `strapi` (o el nombre que prefieras)

### Secret #9: DATABASE_USERNAME
- **Name**: `DATABASE_USERNAME`
- **Value**: `strapi` (o el usuario que prefieras)

### Secret #10: DATABASE_PASSWORD
- **Name**: `DATABASE_PASSWORD`
- **Value**: Una contraseña segura generada

### Secret #11: SSH_HOST
- **Name**: `SSH_HOST`
- **Value**: Tu IP pública de EC2 (ejemplo: `3.25.123.45`)

### Secret #12: SSH_USER
- **Name**: `SSH_USER`
- **Value**:
  - `ubuntu` (si usas Ubuntu)
  - `ec2-user` (si usas Amazon Linux 2)

### Secret #13: SSH_KEY
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

### Secrets Mínimos (Docker Hub únicamente):

```
Repository secrets (7)
├── DOCKERHUB_USERNAME       (Set 1 minute ago)
├── DOCKERHUB_TOKEN          (Set 1 minute ago)
├── APP_KEYS                 (Set 1 minute ago)
├── API_TOKEN_SALT           (Set 1 minute ago)
├── ADMIN_JWT_SECRET         (Set 1 minute ago)
├── JWT_SECRET               (Set 1 minute ago)
└── TRANSFER_TOKEN_SALT      (Set 1 minute ago)
```

### Secrets Completos (Docker Hub + EC2):

```
Repository secrets (13)
├── DOCKERHUB_USERNAME       (Set 1 minute ago)
├── DOCKERHUB_TOKEN          (Set 1 minute ago)
├── APP_KEYS                 (Set 1 minute ago)
├── API_TOKEN_SALT           (Set 1 minute ago)
├── ADMIN_JWT_SECRET         (Set 1 minute ago)
├── JWT_SECRET               (Set 1 minute ago)
├── TRANSFER_TOKEN_SALT      (Set 1 minute ago)
├── DATABASE_NAME            (Set 1 minute ago)
├── DATABASE_USERNAME        (Set 1 minute ago)
├── DATABASE_PASSWORD        (Set 1 minute ago)
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
