pipeline {
    agent any

    environment {
        DOCKER_COMPOSE_PATH = "/usr/local/bin/docker-compose"  // Absolute path to Docker Compose
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/vignesh-018/test-assignment.git'
            }
        }

        stage('Build and Deploy with Docker Compose') {
            steps {
                script {
                    sh '${DOCKER_COMPOSE_PATH} build'
                    sh '${DOCKER_COMPOSE_PATH} up -d'
                }
            }
        }
    }
}


