# Multi-stage build for Flutter passenger app
FROM cirrusci/flutter:3.19 AS build

# App code
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:9090/api/v1 --dart-define=WS_BASE_URL=ws://10.0.2.2:9090/ws

# Runtime stage
FROM openjdk:21-jre-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk /app/app.apk

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

CMD ["bash", "-c", "echo 'Flutter APK built. Copy app.apk from container.'"]
