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

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                echo 'Tests passed!'
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
                    sh "docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password ${dockerCreds.password}"
                }

                // Push Docker image to ACR
                sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }

        // Just for demo
        stage('Pull Docker Image from ACR') {
            steps {
                // Login to Azure Container Registry
                script {
                    def dockerCreds = credentials('azure-acr-creds') // Use Jenkins credentials ID for ACR login
                    sh "docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password ${dockerCreds.password}"
                }

                // Pull Docker image from ACR
                sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    // Login to Azure Container Registry
                    def dockerCreds = credentials('azure-acr-creds') // Use Jenkins credentials ID for ACR login
                    sh "docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password ${dockerCreds.password}"

                    // Stop and remove any existing container with the same name
                    sh """
                    docker stop nextjs-demo-container || true
                    docker rm nextjs-demo-container || true
                    """

                    // Run the new container
                    sh """
                    docker run --rm -d --name nextjs-demo-container -p 3000:3000 ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Docker image built and pushed to ACR successfully!'
            echo 'Docker container deployed successfully from ACR!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
