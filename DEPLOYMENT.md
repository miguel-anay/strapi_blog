# 🚀 Guía de Deployment - Strapi en AWS EC2

Esta guía te ayudará a deployar tu aplicación Strapi en AWS EC2 expuesta directamente con HTTPS.

---

## 📋 Requisitos Previos

- ✅ Cuenta de AWS con EC2 configurado
- ✅ Cuenta de DockerHub
- ✅ Cliente SSH para conectarte al servidor
- ✅ Conocimientos básicos de Linux/Ubuntu

---

## Paso 1: Subir Imagen a DockerHub

### 1.1 Login a DockerHub

```bash
docker login
# Ingresa tu usuario y password
```

### 1.2 Tag y Push la Imagen

```bash
# Tag la imagen
docker tag strapi-app:latest k3n5h1n/strapi-blog:latest

# Push a DockerHub
docker push k3n5h1n/strapi-blog:latest
```

### 1.3 Verificar

Visita: `https://hub.docker.com/r/k3n5h1n/strapi-blog`

---

## Paso 2: Configurar Servidor EC2

### 2.1 Crear Instancia EC2

1. **Tipo de Instancia**: t2.small o t2.medium (mínimo)
2. **Sistema Operativo**: Ubuntu 24.04 LTS
3. **Almacenamiento**: 20-30 GB SSD
4. **Security Group**: Configurar puertos:
   - SSH (22) - Tu IP
   - Custom TCP (1337) - 0.0.0.0/0 (Puerto de Strapi)

### 2.2 Conectar via SSH

```bash
ssh -i tu-llave.pem ubuntu@tu-ip-ec2
```

### 2.3 Actualizar Sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Paso 3: Instalar Dependencias en EC2

### 3.1 Instalar Docker

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

### 3.2 Instalar Docker Compose

```bash
sudo apt install docker-compose -y
docker-compose --version
```

---

## Paso 4: Preparar Aplicación en EC2

### 4.1 Crear Directorio del Proyecto

```bash
mkdir -p ~/strapi
cd ~/strapi
```

### 4.2 Generar Secrets

```bash
# Generar 6 secrets seguros (uno por cada variable)
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
openssl rand -base64 32
```

### 4.3 Crear archivo .env

```bash
nano .env
```

Contenido del `.env` (reemplaza los valores):

```bash
# Server
HOST=0.0.0.0
PORT=1337
NODE_ENV=production

# Database
DATABASE_CLIENT=sqlite
DATABASE_FILENAME=.tmp/data.db

# Docker Image (tu imagen de DockerHub)
DOCKER_IMAGE=tu-usuario/strapi-app:latest

# Security Secrets (USAR VALORES GENERADOS ARRIBA)
APP_KEYS=secret1,secret2,secret3,secret4
API_TOKEN_SALT=secret5
ADMIN_JWT_SECRET=secret6
TRANSFER_TOKEN_SALT=secret7
ENCRYPTION_KEY=secret8
JWT_SECRET=secret9

# Admin cookies (true para HTTPS, false para HTTP)
ADMIN_SECURE_COOKIE=false
```

**⚠️ IMPORTANTE**:
- Si usas HTTPS: `ADMIN_SECURE_COOKIE=true`
- Si usas HTTP: `ADMIN_SECURE_COOKIE=false`

### 4.4 Crear docker-compose.prod.yml

```bash
nano docker-compose.prod.yml
```

Contenido:

```yaml
version: "3.8"

services:
  strapi:
    container_name: strapi
    image: ${DOCKER_IMAGE:-strapi-app:latest}
    restart: unless-stopped
    environment:
      HOST: 0.0.0.0
      PORT: 1337
      NODE_ENV: production
      ADMIN_SECURE_COOKIE: ${ADMIN_SECURE_COOKIE:-false}
      DATABASE_CLIENT: sqlite
      DATABASE_FILENAME: .tmp/data.db
      APP_KEYS: ${APP_KEYS}
      API_TOKEN_SALT: ${API_TOKEN_SALT}
      ADMIN_JWT_SECRET: ${ADMIN_JWT_SECRET}
      TRANSFER_TOKEN_SALT: ${TRANSFER_TOKEN_SALT}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "1337:1337"
    volumes:
      - ./data:/app/.tmp
      - ./public/uploads:/app/public/uploads
    networks:
      - strapi

networks:
  strapi:
    name: strapi-network
    driver: bridge
```

---

## Paso 5: Deployar Strapi

### 5.1 Pull de la Imagen

```bash
cd ~/strapi
docker pull k3n5h1n/strapi-blog:latest
```

### 5.2 Iniciar Servicios

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 5.3 Verificar Estado

```bash
# Ver logs
docker-compose -f docker-compose.prod.yml logs -f strapi

# Ver estado
docker-compose -f docker-compose.prod.yml ps
```

### 5.4 Acceder a la Aplicación

1. Abre tu navegador: `http://tu-ip-ec2:1337/admin`
2. Crea tu primer usuario administrador
3. ¡Listo! 🎉

---

## Acceso

- **Panel Admin**: `http://tu-ip-ec2:1337/admin`
- **API**: `http://tu-ip-ec2:1337/api`

---

## Mantenimiento

### Ver Logs

```bash
docker-compose -f docker-compose.prod.yml logs -f strapi
```

### Reiniciar Strapi

```bash
docker-compose -f docker-compose.prod.yml restart strapi
```

### Actualizar Aplicación

```bash
# 1. Hacer cambios locales y rebuild
docker build -t strapi-app:latest .
docker tag strapi-app:latest k3n5h1n/strapi-blog:latest
docker push k3n5h1n/strapi-blog:latest

# 2. En el servidor EC2
cd ~/strapi
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

### Backup de Base de Datos

```bash
# Backup manual
cd ~/strapi
tar -czf backup-$(date +%Y%m%d).tar.gz data/ public/uploads/

# Descargar a local
scp -i tu-llave.pem ubuntu@tu-ip-ec2:~/strapi/backup-*.tar.gz ./
```

---

## Problemas Comunes

### 1. No puedo acceder al puerto 1337
**Solución**: Verificar Security Group de EC2 que permita el puerto 1337

### 2. Error 502 Bad Gateway
**Solución**: Verificar que Strapi esté corriendo:
```bash
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs strapi
```

### 3. No puede crear usuario admin
**Solución**: Si usas HTTP, asegúrate que `ADMIN_SECURE_COOKIE=false` en el .env

### 4. Mensaje CSP en logs
**Nota**: El mensaje de Content Security Policy es normal, no es un error:
```
connect-src 'self' https:;img-src 'self' data: blob: ...
```
Esto es solo información de headers de seguridad, no afecta el funcionamiento.

---

## Seguridad en Producción

### Recomendaciones:

1. **Usar HTTPS**: Configura un certificado SSL/TLS
2. **Firewall**: Limita acceso al puerto 1337 solo desde IPs conocidas
3. **Backups**: Automatiza backups regulares
4. **Actualiza**: Mantén Docker y Strapi actualizados

---

## ✅ Checklist de Deployment

- [ ] Imagen subida a DockerHub
- [ ] EC2 creado y configurado
- [ ] Security Group con puerto 1337 abierto
- [ ] Docker y Docker Compose instalados
- [ ] Variables de entorno configuradas (.env)
- [ ] docker-compose.prod.yml creado
- [ ] Strapi corriendo en Docker
- [ ] Usuario admin creado
- [ ] Backup configurado

---

**¡Tu aplicación Strapi está en producción! 🚀**

Para usar con HTTPS, necesitarás configurar un certificado SSL y cambiar `ADMIN_SECURE_COOKIE=true` en tu .env.
