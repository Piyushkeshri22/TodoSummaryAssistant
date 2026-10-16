
# Stage 1: Build the Spring Boot application
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy Maven configuration and source code
COPY pom.xml .
COPY src ./src

# Compile, test, and package the application
RUN mvn -B clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Create a dedicated non-root user
RUN addgroup -S spring \
    && adduser -S spring -G spring

# Copy the packaged Spring Boot JAR
COPY --from=build /app/target/*.jar app.jar

# Run as a non-root user
USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
