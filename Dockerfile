# Dockerfile para Strapi v5.24.1
# Construcción multi-etapa para optimizar el tamaño de la imagen

# ===== ETAPA 1: Construcción =====
FROM node:20-alpine AS build

# Instalar dependencias del sistema necesarias para compilación
RUN apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    vips-dev \
    git \
    python3

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias (incluyendo devDependencies para build)
RUN npm install

# Copiar el resto del código
COPY . .

# Variables de entorno para build
ENV NODE_ENV=production

# Construir el panel de administración de Strapi
RUN npm run build

# ===== ETAPA 2: Producción =====
FROM node:20-alpine AS production

# Instalar solo las dependencias runtime necesarias
RUN apk add --no-cache \
    vips-dev \
    libpng-dev

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S strapi && \
    adduser -S strapi -u 1001

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm install --only=production && \
    npm cache clean --force

# Copiar código construido desde la etapa de build
COPY --from=build --chown=strapi:strapi /app/dist ./dist
COPY --from=build --chown=strapi:strapi /app/public ./public
COPY --from=build --chown=strapi:strapi /app/database ./database
COPY --from=build --chown=strapi:strapi /app/scripts ./scripts

# Copiar archivos de configuración TypeScript originales
COPY --chown=strapi:strapi ./config ./config
COPY --chown=strapi:strapi ./src ./src
COPY --chown=strapi:strapi ./tsconfig.json ./tsconfig.json

# Crear directorios necesarios con permisos correctos
RUN mkdir -p .cache .tmp data public/uploads && \
    chown -R strapi:strapi /app

# Cambiar a usuario no-root
USER strapi

# Exponer puerto de Strapi
EXPOSE 1337

# Variables de entorno por defecto
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=1337

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD node -e "require('http').get('http://localhost:1337/_health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando de inicio
CMD ["npm", "run", "start"]
