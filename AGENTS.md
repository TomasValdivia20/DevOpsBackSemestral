# AGENTS.md — DevOps Backend Semestral

Monorepo con dos microservicios Spring Boot 3.4.4 / Java 17 independientes:
- **Ventas** (`back-Ventas_SpringBoot/Springboot-API-REST/`, puerto 8081, endpoint `api/v1/ventas`)
- **Despachos** (`back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/`, puerto 8082, endpoint `api/v1/despachos`)

## Comandos

```bash
# Build sin tests (desde el directorio del pom.xml correspondiente)
./mvnw clean package -DskipTests

# Tests
./mvnw test                              # todos
./mvnw test -Dtest=VentaServiceTest       # clase específica

# Docker Compose local (desde la raíz)
docker compose up -d --build
```

## CI/CD

**Pipeline**: `.github/workflows/deploy.yml`
**Trigger**: push a la rama `deploy` únicamente
**Infraestructura**: ECS Fargate (no EC2)
**Flujo** (jobs paralelos por servicio):
1. Build con Docker Buildx → push a **Amazon ECR** (`innovatech-backend-ventas`, `innovatech-backend-despacho`)
2. Descargar task definition actual desde ECS vía `describe-services` → `describe-task-definition`
3. Render: actualizar imagen + limpiar metadatos computados
4. Registrar nueva revisión de task definition + `update-service --force-new-deployment`

**Secrets requeridos en GitHub**:
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, y los 10 de RDS (ver `.env.example`).

## Arquitectura

| Aspecto | Detalle |
|---|---|
| Base de datos | MySQL en AWS RDS (instancia separada por servicio) |
| JPA | Hibernate con `ddl-auto=update` — las tablas se crean solas |
| Documentación API | Swagger UI en `/swagger-ui.html` (springdoc-openapi) |
| Build | Multi-stage Docker (`maven:3.9.6-eclipse-temurin-17` → `eclipse-temurin:17-jre-alpine`) |
| Seguridad | Contenedor con usuario no root, health check con `curl` |
| JVM | `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0` |
| CORS | Ambos servicios tienen `@CrossOrigin(origins = "*")`. Despachos además tiene un `CorsConfig` bean (doble configuración). |

## Variables de entorno

Las apps Spring Boot leen estas variables (definidas en `.env` o pasadas por Docker Compose):

| Variable | Servicio |
|---|---|
| `DB_ENDPOINT_VENTAS`, `DB_PORT_VENTAS`, `DB_NAME_VENTAS`, `DB_USERNAME_VENTAS`, `DB_PASSWORD_VENTAS` | Ventas |
| `DB_ENDPOINT_DESPACHOS`, `DB_PORT_DESPACHOS`, `DB_NAME_DESPACHOS`, `DB_USERNAME_DESPACHOS`, `DB_PASSWORD_DESPACHOS` | Despachos |
| `SERVICE_PORT` | Opcional — override del puerto del contenedor |

## Gotchas

- **Tests de Despachos**: Solo tiene un `@SpringBootTest` de context-load. No tiene `application-test.properties` ni tests unitarios con Mockito (a diferencia de Ventas).
- **`init.sql`**: Es solo referencia documental. Hibernate se encarga del schema via `ddl-auto=update`.
- **CORS duplicado en Despachos**: Tiene `CorsConfig` bean + `@CrossOrigin("*")` en el controller. Ventas solo usa la anotación.
