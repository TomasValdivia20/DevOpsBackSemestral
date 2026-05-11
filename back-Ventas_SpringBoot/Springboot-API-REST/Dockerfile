# ================================================================
# STAGE 1: Builder — compila el proyecto con Maven
# ================================================================
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copiar pom.xml primero → Maven descarga dependencias en esta capa
# Si pom.xml no cambia, la capa se cachea y el build es mucho más rápido
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY back-Ventas_SpringBoot/Springboot-API-REST/src ./src

# Compilar y empaquetar (saltamos tests: se ejecutan en CI por separado)
RUN mvn package -DskipTests -B

# ================================================================
# STAGE 2: Runner — imagen JRE mínima para producción
# ================================================================
FROM eclipse-temurin:17-jre-alpine AS runner

# Crear usuario y grupo no root (principio mínimo privilegio)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copiar SOLO el JAR generado desde el stage builder
# No copiamos código fuente ni dependencias de Maven → imagen mucho más pequeña
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar

# Usar usuario no root antes de ejecutar
USER appuser

# Puerto del servicio Ventas (configurado en application.properties: 8080 default)
EXPOSE 8080

# Health check: verifica que el servicio responde
# Espera 60s de inicio (Spring Boot tarda en arrancar)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/api/v1/ventas 2>/dev/null && echo "OK" || exit 1

# Ejecutar el JAR con opciones JVM optimizadas para contenedor
CMD ["java", \
     "-XX:+UseContainerSupport", \
     "-XX:MaxRAMPercentage=75.0", \
     "-jar", "app.jar"]
