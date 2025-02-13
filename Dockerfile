# Stage 1: Build the WAR file using Maven
FROM maven:3.8.7-openjdk-11 AS build

# Set working directory inside the container
WORKDIR /app

# Copy the source code
COPY . .

# Download the project dependencies
RUN mvn dependency:go-offline

# Build the application (WAR file will be inside target/)
RUN mvn package

# Stage 2: Run the WAR file inside Tomcat
FROM tomcat:9.0

# Set working directory to Tomcat's webapps
WORKDIR /usr/local/tomcat/webapps/

# Copy the built WAR file from the previous stage
COPY --from=build /app/target/*.war app.war

# Expose Tomcat's port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
