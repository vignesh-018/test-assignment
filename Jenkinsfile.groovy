pipeline {
    agent any

    environment {
        TOMCAT_CREDENTIALS = credentials('tomcat-credentials')  
        TOMCAT_URL = "${env.tom-url}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/vignesh-018/test-assignment.git'  
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package' 
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'  
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
                    
                    env.WAR_FILE = warFileName
                    echo "WAR file found: ${env.WAR_FILE}"
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    sh """
                    curl -u ${TOMCAT_CREDENTIALS_USR}:${TOMCAT_CREDENTIALS_PSW} -T ${WAR_FILE} ${TOMCAT_URL}/manager/text/deploy?path=/app&update=true
                    """
                }
            }
        }
    }
}
