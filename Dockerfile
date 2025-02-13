# Stage 1: Use a plain Ubuntu image and install dependencies
FROM ubuntu:20.04 AS build

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Java, Maven, Git, and Tomcat
RUN apt update && apt install -y \
    openjdk-21-jdk \
    maven \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files into the container
COPY pom.xml .

# Build the Spring Boot application (WAR)
RUN mvn pacjkage

# Stage 2: Use a plain Ubuntu image for deployment
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Install Java & Tomcat manually
RUN apt update && apt install -y \
    openjdk-21-jdk \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Tomcat manually
RUN wget https://downloads.apache.org/tomcat/tomcat-10/v10.1.16/bin/apache-tomcat-10.1.16.tar.gz \
    && tar -xvzf apache-tomcat-10.1.16.tar.gz \
    && mv apache-tomcat-10.1.16 /opt/tomcat \
    && rm apache-tomcat-10.1.16.tar.gz

# Set Tomcat environment variables
ENV CATALINA_HOME=/opt/tomcat
ENV PATH="$CATALINA_HOME/bin:$PATH"

# Set working directory to Tomcat webapps
WORKDIR /opt/tomcat/webapps/

# Copy the built WAR file from the build stage
COPY --from=build /app/target/test-0.0.1-SNAPSHOT.war /opt/tomcat/webapps/test.war

# Expose Tomcat port
EXPOSE 8000

# Start Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
