# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

# Gradle wrapper + build config
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY gradle/wrapper gradle/wrapper

# Dependencies (cached unless build files change)
RUN chmod +x gradlew && ./gradlew dependencies --no-daemon || true

# Source
COPY src src

# Build (skip tests for smaller image)
RUN ./gradlew bootJar -x test --no-daemon

# Run stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# JAR from build stage (Spring Boot names it with version)
COPY --from=build /app/build/libs/auth-backend-*.jar app.jar

# Non-root user
RUN adduser -D -g "" appuser && chown -R appuser:appuser /app
USER appuser

# Port
EXPOSE 8080

# Default: run the app; PORT for Cloud Run / Railway
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar"]
