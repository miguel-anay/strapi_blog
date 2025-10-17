# 🚀 Guía de Deployment - Strapi en AWS EC2 con Git

Esta guía te ayudará a deployar tu aplicación Strapi en AWS EC2 usando Git y Docker.

---

## 📋 Requisitos Previos

- ✅ Cuenta de AWS con EC2 configurado
- ✅ Cuenta de GitHub
- ✅ Cuenta de DockerHub
- ✅ Cliente SSH para conectarte al servidor
- ✅ Git instalado localmente

---

## 🐳 Paso 1: Preparar Imagen Docker

### 1.1 Build Local (Opcional)

Si quieres probar localmente antes de subir:

```bash
# Build imagen
docker build -t strapi-app:latest .

# Probar localmente
docker-compose up -d

# Ver logs
docker-compose logs -f strapi
```

### 1.2 Subir a DockerHub

```bash
# Tag la imagen
docker tag strapi-app:latest k3n5h1n/strapi-blog:latest

# Push a DockerHub
docker push k3n5h1n/strapi-blog:latest
```

**Verificar**: `https://hub.docker.com/r/k3n5h1n/strapi-blog`

---

## 📦 Paso 2: Preparar Repositorio Git

### 2.1 Commit y Push

```bash
# Agregar cambios
git add .

# Commit
git commit -m "Update Strapi configuration"

# Push a GitHub
git push origin master
```

**Repositorio**: `https://github.com/miguel-anay/strapi_blog.git`

---

## ☁️ Paso 3: Configurar Servidor EC2

### 3.1 Crear Instancia EC2

1. **Tipo de Instancia**: t2.small o t2.medium (mínimo)
2. **Sistema Operativo**: Ubuntu 24.04 LTS
3. **Almacenamiento**: 20-30 GB SSD
4. **Security Group**: Configurar puertos:
   - SSH (22) - Tu IP
   - Custom TCP (1337) - 0.0.0.0/0 (Puerto de Strapi)

### 3.2 Conectar via SSH

```bash
ssh -i tu-llave.pem ubuntu@TU-IP-EC2
```

### 3.3 Actualizar Sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 🔧 Paso 4: Instalar Dependencias en EC2

### 4.1 Instalar Docker

```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Recargar grupos (o reconectar SSH)
newgrp docker

# Verificar
docker --version
```

### 4.2 Instalar Docker Compose

```bash
sudo apt install docker-compose -y
docker-compose --version
```

### 4.3 Instalar Git

```bash
sudo apt install git -y
git --version
```

---

## 📥 Paso 5: Clonar Repositorio en EC2

### 5.1 Clonar desde GitHub

```bash
cd /home/ubuntu
git clone https://github.com/miguel-anay/strapi_blog.git
cd strapi_blog
```

### 5.2 Verificar Archivos

```bash
ls -la
# Deberías ver: Dockerfile, docker-compose.prod.yml, src/, config/, etc.
```

---

## ⚙️ Paso 6: Configurar Variables de Entorno

### 6.1 Crear archivo .env

⚠️ **IMPORTANTE**: El archivo `.env` NO está en Git por seguridad. Debes crearlo manualmente.

```bash
nano .env
```

### 6.2 Contenido del .env

Copia y pega esto, reemplazando los valores:

```bash
# ===========================================
# SERVER
# ===========================================
HOST=0.0.0.0
PORT=1337
NODE_ENV=production

# ===========================================
# DOCKER IMAGE
# ===========================================
DOCKER_IMAGE=k3n5h1n/strapi-blog:latest

# ===========================================
# SECURITY SECRETS
# ===========================================
# ⚠️ GENERAR NUEVOS VALORES con: openssl rand -base64 32
APP_KEYS=secret1,secret2,secret3,secret4
API_TOKEN_SALT=tuSecretAqui
ADMIN_JWT_SECRET=tuSecretAqui
TRANSFER_TOKEN_SALT=tuSecretAqui
ENCRYPTION_KEY=tuSecretAqui
JWT_SECRET=tuSecretAqui

# ===========================================
# DATABASE
# ===========================================
DATABASE_CLIENT=sqlite
DATABASE_FILENAME=.tmp/data.db

# ===========================================
# ADMIN (false para HTTP, true para HTTPS)
# ===========================================
ADMIN_SECURE_COOKIE=false
```

### 6.3 Generar Secrets Seguros

```bash
# Generar 6 secrets seguros
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
```

Copia estos valores y reemplaza en el `.env`.

**💡 Tip**: Si ya tienes un `.env` local con datos, puedes transferirlo con SCP:

```bash
# Desde tu máquina local
scp -i tu-llave.pem .env ubuntu@TU-IP-EC2:/home/ubuntu/strapi_blog/
```

---

## 🚀 Paso 7: Deployar Strapi

### 7.1 Pull de la Imagen desde DockerHub

```bash
cd /home/ubuntu/strapi_blog
docker pull k3n5h1n/strapi-blog:latest
```

### 7.2 Iniciar Servicios con Docker Compose

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 7.3 Verificar Estado

```bash
# Ver logs
docker-compose -f docker-compose.prod.yml logs -f strapi

# Ver estado
docker-compose -f docker-compose.prod.yml ps
```

### 7.4 Acceder a la Aplicación

1. Abre tu navegador: `http://TU-IP-EC2:1337/admin`
2. Crea tu primer usuario administrador (si es primera vez)
3. ¡Listo! 🎉

---

## 🔄 Paso 8: Actualizar la Aplicación

Cuando hagas cambios en tu código:

### 8.1 Desde tu Máquina Local

```bash
# 1. Hacer cambios en el código
# 2. Build nueva imagen
docker build -t strapi-app:latest .

# 3. Tag y push a DockerHub
docker tag strapi-app:latest k3n5h1n/strapi-blog:latest
docker push k3n5h1n/strapi-blog:latest

# 4. Commit y push a GitHub
git add .
git commit -m "Descripción de cambios"
git push origin master
```

### 8.2 En el Servidor EC2

```bash
# Conectar al servidor
ssh -i tu-llave.pem ubuntu@TU-IP-EC2

# Ir al directorio
cd /home/ubuntu/strapi_blog

# Pull cambios de Git (archivos de configuración)
git pull origin master

# Pull nueva imagen de Docker
docker-compose -f docker-compose.prod.yml pull

# Reiniciar servicios
docker-compose -f docker-compose.prod.yml up -d

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f strapi
```

---

## 🌐 Acceso

- **Panel Admin**: `http://TU-IP-EC2:1337/admin`
- **API**: `http://TU-IP-EC2:1337/api`

---

## 🛠️ Mantenimiento

### Ver Logs

```bash
docker-compose -f docker-compose.prod.yml logs -f strapi
```

### Reiniciar Strapi

```bash
docker-compose -f docker-compose.prod.yml restart strapi
```

### Detener Servicios

```bash
docker-compose -f docker-compose.prod.yml down
```

### Backup de Base de Datos

```bash
# Backup manual
cd /home/ubuntu/strapi_blog
tar -czf backup-$(date +%Y%m%d).tar.gz data/ public/uploads/

# Descargar a local
scp -i tu-llave.pem ubuntu@TU-IP-EC2:/home/ubuntu/strapi_blog/backup-*.tar.gz ./
```

### Restaurar Base de Datos

```bash
# Subir backup al servidor
scp -i tu-llave.pem backup-20231017.tar.gz ubuntu@TU-IP-EC2:/home/ubuntu/strapi_blog/

# En el servidor
cd /home/ubuntu/strapi_blog
docker-compose -f docker-compose.prod.yml down
tar -xzf backup-20231017.tar.gz
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🐛 Problemas Comunes

### 1. No puedo acceder al puerto 1337

**Solución**: Verificar Security Group de EC2 que permita el puerto 1337

```bash
# En AWS Console > EC2 > Security Groups
# Agregar regla: Custom TCP | Port 1337 | Source: 0.0.0.0/0
```

### 2. Error 502 Bad Gateway

**Solución**: Verificar que Strapi esté corriendo:

```bash
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs strapi
```

### 3. No puede crear usuario admin

**Solución**: Si usas HTTP, asegúrate que `ADMIN_SECURE_COOKIE=false` en el .env

### 4. Error "Cannot send secure cookie"

**Solución**: Verifica que `ADMIN_SECURE_COOKIE=false` en tu `.env` si no usas HTTPS.

### 5. La imagen Docker no se actualiza

**Solución**: Pull explícito de la nueva imagen:

```bash
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### 6. Cambios en Git no se reflejan

**Solución**: Asegúrate de hacer `git pull` en el servidor:

```bash
cd /home/ubuntu/strapi_blog
git pull origin master
```

---

## 🔒 Seguridad en Producción

### Recomendaciones:

1. **Usar HTTPS**: Configura un certificado SSL/TLS con Let's Encrypt
2. **Firewall**: Limita acceso al puerto 1337 solo desde IPs conocidas
3. **Secrets**: NUNCA subas el archivo `.env` a Git
4. **Backups**: Automatiza backups regulares de la base de datos
5. **Actualiza**: Mantén Docker y Strapi actualizados

### Configurar HTTPS (Opcional)

Si quieres usar HTTPS con un dominio:

1. Obtén un dominio y apúntalo a tu IP de EC2
2. Instala Nginx y Certbot:
   ```bash
   sudo apt install nginx certbot python3-certbot-nginx -y
   ```
3. Configura Nginx como proxy inverso
4. Obtén certificado SSL:
   ```bash
   sudo certbot --nginx -d tudominio.com
   ```
5. Cambia en `.env`:
   ```bash
   ADMIN_SECURE_COOKIE=true
   ```

---

## 📊 Monitoreo

### Verificar Salud del Contenedor

```bash
docker inspect strapi | grep Status -A 5
```

### Verificar Uso de Recursos

```bash
docker stats strapi
```

### Health Check Automático

El `docker-compose.prod.yml` incluye un health check que verifica la salud de Strapi cada 30 segundos.

---

## ✅ Checklist de Deployment

- [ ] Imagen Docker subida a DockerHub (`k3n5h1n/strapi-blog:latest`)
- [ ] Código pusheado a GitHub (`miguel-anay/strapi_blog`)
- [ ] EC2 creado y configurado
- [ ] Security Group con puerto 1337 abierto
- [ ] Docker y Docker Compose instalados en EC2
- [ ] Git instalado en EC2
- [ ] Repositorio clonado en EC2
- [ ] Archivo `.env` creado con secrets seguros
- [ ] Imagen Docker pulled desde DockerHub
- [ ] Strapi corriendo con `docker-compose`
- [ ] Usuario admin creado
- [ ] Backup configurado

---

## 🔗 Enlaces Útiles

- **Repositorio GitHub**: https://github.com/miguel-anay/strapi_blog
- **Imagen DockerHub**: https://hub.docker.com/r/k3n5h1n/strapi-blog
- **Documentación Strapi**: https://docs.strapi.io
- **Docker Docs**: https://docs.docker.com

---

**¡Tu aplicación Strapi está lista para producción con Git! 🚀**

Para actualizaciones futuras, simplemente push a GitHub y pull en el servidor.
