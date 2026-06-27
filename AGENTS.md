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
**Flujo**:
1. Build + push a Docker Hub (`tomasvaldivia20/backend-ventas`, `tomasvaldivia20/backend-despachos`)
2. SCP de `docker-compose.yml`, `init.sql`, `.env.example` al EC2
3. SSH a EC2 (vía bastion/frontend) → genera `.env` desde GitHub Secrets → `docker pull` + `docker-compose up -d`

**Secrets requeridos en GitHub**:
`DOCKERHUB_TOKEN`, `EC2_BACKEND_HOST`, `EC2_FRONTEND_HOST`, `EC2_USER`, `EC2_SSH_KEY`, y los 10 de RDS (ver `.env.example`).

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
