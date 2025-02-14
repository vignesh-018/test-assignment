pipeline {
    agent any 

    environment {

        TOMCAT_CREDENTIALS = credentials('tomcat-credentials') // Retrieves Tomcat credentials stored in Jenkins
        TOMCAT_URL = credentials('tom-url') // Retrieves Tomcat URL stored in Jenkins
    }

    stages {

        stage('Checkout Code') {
            // Stage for checking out the source code
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/vignesh-018/test-assignment.git' // Checks out code from the specified Git repository.  
            }
        }

        stage('Build') {
            // Stage for building the application
            steps {
                sh 'mvn clean package' // Executes a Maven command to clean, compile, package, and generate a WAR file
            }
        }

        stage('Test') {
            // Stage for running unit tests
            steps {
                sh 'mvn test' 
            }
        }

        stage('Find WAR File') {
            // Stage to locate the generated WAR file
            steps {
                script {
                    // Groovy script to find the WAR file
                    def workspacePath = env.WORKSPACE // Gets the Jenkins workspace path
                    def warFileName = sh(script: "find ${workspacePath} -type f -name '*.war' | head -n 1", returnStdout: true).trim() // Finds the first .war file in the workspace

                    if (!warFileName) {
                        error "WAR file not found in workspace" // Throws an error if no WAR file is found
                    }

                    env.WAR_FILE = warFileName // Stores the WAR file path in an environment variable for later use
                    echo "WAR file found: ${env.WAR_FILE}" // Prints the WAR file path to the console
                }
            }
        }

        stage('Deploy to Tomcat') {
            // Stage for deploying the WAR file to Tomcat
            steps {
                script {
                    // Groovy script to deploy to Tomcat
                    withCredentials([usernamePassword(credentialsId: 'tomcat-credentials', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                        // Uses Jenkins credentials to get username and password for Tomcat
                        sh """
                            curl -s -u ${Username}:${Password} -T ${env.WAR_FILE} ${TOMCAT_URL}/manager/text/deploy?path=/test-app&update=true
                        """

                    }
                }
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

