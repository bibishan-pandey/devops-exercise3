pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "nextjsdemoacr.azurecr.io"
        DOCKER_IMAGE_NAME = "nextjs-demo-image"
        DOCKER_IMAGE_TAG = "latest"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/bibishan-pandey/devops-exercise3.git'
            }
        }

        stage('Pull Docker Image from ACR') {
            steps {
                // Login to Azure Container Registry
                script {
                    def dockerCreds = credentials('azure-acr-creds') // Use Jenkins credentials ID for ACR login
                    sh "echo ${dockerCreds.password} | docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password-stdin"
                }

                // Pull Docker image from ACR
                sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    // Stop and remove any existing container with the same name
                    sh """
                    docker stop nextjs-demo-container || true
                    docker rm nextjs-demo-container || true
                    """

                    // Run the new container
                    sh """
                    docker run -d --name nextjs-demo-container -p 80:3000 ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Docker container deployed successfully from ACR!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
