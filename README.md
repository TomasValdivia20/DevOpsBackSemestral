# 🚀 Innovatech - Backend Microservices

Este es el componente Backend para el ecosistema de **Innovatech**, construido utilizando arquitectura de microservicios con **Spring Boot**. Se encarga de procesar la lógica de negocio principal y gestionar la persistencia de datos de manera eficiente.

## 🛠️ Tecnologías Utilizadas

* **Java** (Versión 17 o superior)
* **Spring Boot 3.x** (Spring Web, Spring Data JPA)
* **MySQL Connector/J 9.1.0** (Persistencia de datos)
* **Maven** (Gestor de dependencias)

## 🏗️ Microservicios Incluidos

El backend se divide en los siguientes módulos principales:
* **Servicio de Ventas (Port 8081):** Gestiona la creación, consulta y procesamiento de transacciones comerciales.
* **Servicio de Despachos (Port 8082):** Administra los estados de envío, asignación de rutas y logística de entrega.

---

## ⚙️ Configuración Local

### 1. Requisitos Previos
Asegúrate de tener instalado:
* Java JDK 17
* Maven 3.x
* Una instancia de MySQL ejecutándose localmente o en la nube (AWS RDS).

### 2. Variables de Entorno y Conexión (`application.properties`)
Para conectar correctamente la base de datos (especialmente si usas versiones recientes como Connector/J 9.x), asegúrate de que tu cadena de conexión use `sslMode`:

```properties
spring.datasource.url=jdbc:mysql://[TU_HOST_O_IP]:3306/[TU_BASE_DATOS]?sslMode=DISABLED&allowPublicKeyRetrieval=true
spring.datasource.username=[TU_USUARIO]
spring.datasource.password=[TU_CONTRASENA]
3. Compilar y Ejecutar
Para compilar el proyecto y descargar las dependencias, ejecuta en la raíz de cada microservicio:

Bash
mvn clean install
Para iniciar la aplicación:

Bash
mvn spring-boot:run
🛣️ Endpoints Principales (API)
Puedes probar las peticiones utilizando herramientas como Postman:

Ventas: GET /api/v1/ventas o POST /api/v1/ventas

Despachos: GET /api/v1/despachos o POST /api/v1/despachos
