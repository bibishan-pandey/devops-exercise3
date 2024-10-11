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

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                // Login to Azure Container Registry
                script {
                    def dockerCreds = credentials('azure-acr-creds') // Use the ID from Jenkins credentials
                    sh "echo ${dockerCreds.password} | docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password-stdin"
                }

                // Push Docker image to ACR
                sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo 'Docker image built and pushed to ACR successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
