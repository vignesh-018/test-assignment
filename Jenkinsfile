pipeline {
    agent any

    environment {
        TOMCAT_CREDENTIALS = credentials('tomcat-credentials')  // Retrieve Tomcat credentials
        TOMCAT_URL = credentials('tom-url')  // Retrieve Tomcat URL
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/vignesh-018/test-assignment.git'  // Replace with your actual Git repository
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'  // Builds the Java application and generates a .war file
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'  // Runs unit tests
            }
        }

        stage('Find WAR File') {
            steps {
                script {
                    def workspacePath = env.WORKSPACE  
                    def warFileName = sh(script: "find ${workspacePath} -type f -name '*.war' | head -n 1", returnStdout: true).trim()
                    
                    if (!warFileName) {
                        error "WAR file not found in workspace"
                    }
                    
                    env.WAR_FILE = warFileName  // Store WAR file path as an environment variable
                    echo "WAR file found: ${env.WAR_FILE}"
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'tomcat-credentials', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                        sh """
                        curl -s -u ${TOMCAT_USER}:${TOMCAT_PASS} -T ${WAR_FILE} ${TOMCAT_URL}/manager/text/deploy?path=/app&update=true
                        """
                    }
                }
            }
