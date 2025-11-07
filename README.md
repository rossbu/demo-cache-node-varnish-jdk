# demo-cache-node-varnish-jdk

A proof-of-concept demonstration of a multi-tier caching architecture using Docker Compose with three services:
1. **Frontend** - Simple HTML/JS interface (port 3000)
2. **Varnish Cache** - HTTP accelerator with grace mode (port 8081)
3. **Backend** - Spring Boot REST API with JDK 21 (port 8080)

## Architecture

```
Frontend (Nginx:3000) → Varnish Cache (:8081) → Backend (Spring Boot:8080)
```

The flow demonstrates how Varnish acts as a caching reverse proxy between the frontend and backend, with grace mode enabled to serve stale content if the backend becomes unavailable.

## Features

- **Frontend**: Interactive web UI to fetch data and display cache statistics
- **Varnish**: Configured with grace mode (2-hour grace period) and health checks
- **Backend**: Spring Boot application with `/api/data` endpoint returning mock JSON
- **Docker Compose**: Orchestrates all services with proper networking and health checks

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/rossbu/demo-cache-node-varnish-jdk.git
cd demo-cache-node-varnish-jdk
```

2. Build the backend (requires JDK 21):
```bash
cd backend
./gradlew build -x test
cd ..
```

3. Start all services:
```bash
docker-compose up --build
```

3. Access the frontend:
```
http://localhost:3000
```

4. Test the backend directly (bypassing cache):
```bash
curl http://localhost:8080/api/data
```

5. Test via Varnish cache:
```bash
curl http://localhost:8081/api/data
```

## Service Details

### Frontend (Port 3000)
- Built with Nginx serving a static HTML page
- Interactive UI to demonstrate caching behavior
- Shows cache HIT/MISS status and response times

### Varnish Cache (Port 8081)
- Uses Varnish 7.4
- Configured with `default.vcl` including:
  - Grace mode (2-hour grace period)
  - Backend health checks
  - CORS headers for frontend
  - Cache status headers (X-Cache, X-Cache-Hits)

### Backend (Port 8080)
- Spring Boot 3.2.0 with JDK 21
- Built with Gradle
- Provides `/api/data` endpoint with mock JSON response
- Returns Cache-Control headers for proper caching

## Testing Cache Behavior

1. **First Request** (Cache MISS):
```bash
curl -i http://localhost:8081/api/data
```
Response will include: `X-Cache: MISS`

2. **Subsequent Requests** (Cache HIT):
```bash
curl -i http://localhost:8081/api/data
```
Response will include: `X-Cache: HIT` and `X-Cache-Hits: N`

3. **Force Cache Bypass**:
```bash
curl -H "Cache-Control: no-cache" http://localhost:8081/api/data
```

## Stopping Services

```bash
docker-compose down
```

To remove all data:
```bash
docker-compose down -v
```

## Project Structure

```
.
├── docker-compose.yml          # Orchestrates all services
├── backend/
│   ├── Dockerfile             # Backend container configuration
│   ├── build.gradle           # Gradle build file
│   ├── settings.gradle
│   └── src/
│       └── main/
│           ├── java/com/example/demo/
│           │   ├── DemoApplication.java
│           │   └── DataController.java
│           └── resources/
│               └── application.properties
├── varnish/
│   └── default.vcl            # Varnish configuration with grace mode
└── frontend/
    ├── Dockerfile             # Frontend container configuration
    ├── nginx.conf             # Nginx configuration
    └── index.html             # Frontend UI
```

## License

This is a demonstration project for educational purposes.