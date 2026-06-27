# ================================================================
# STAGE 1: Builder — Compilación optimizada
# ================================================================
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Cachear dependencias de Maven
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar código fuente y compilar
COPY src ./src
RUN mvn clean package -DskipTests -B

# ================================================================
# STAGE 2: Runner — Imagen final segura y de mínimo privilegio
# ================================================================
FROM eclipse-temurin:17-jre-alpine AS runner

# Instalar dependencias necesarias para el Healthcheck (curl o wget si faltan)
RUN apk add --no-cache curl

# Crear usuario no root (Exigido por la pauta de seguridad)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Parámetros configurables en tiempo de build (Evita duplicar código)
ARG PORT=8080
ARG HEALTH_PATH=/api/v1/health

# Pasar los argumentos a variables de entorno para que persistan en el contenedor
ENV SERVICE_PORT=${PORT}
ENV SERVICE_HEALTH_PATH=${HEALTH_PATH}

# Copiar el JAR evitando conflictos de comodines (usando un renombrado limpio en el pom si es necesario o apuntando directo)
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar

USER appuser

# Exponer dinámicamente el puerto configurado
EXPOSE ${SERVICE_PORT}

# Health check corregido usando curl (más confiable) y variables dinámicas
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${SERVICE_PORT}${SERVICE_HEALTH_PATH} || exit 1

# Opciones JVM optimizadas para el uso de memoria en contenedores de AWS
CMD ["java", \
     "-XX:+UseContainerSupport", \
     "-XX:MaxRAMPercentage=75.0", \
     "-jar", "app.jar"]