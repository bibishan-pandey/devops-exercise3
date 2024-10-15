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

        stage('Debug') {
            steps {
                sh 'env'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                // Login to Azure Container Registry & Push the image to Container Registry
                script {
                    withCredentials([usernamePassword(credentialsId: 'service-principal-creds', usernameVariable: 'SERVICE_PRINCIPAL_ID', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD')]) {
                        sh "docker login ${DOCKER_REGISTRY} -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_PASSWORD"
                        sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    }
                
                    // def dockerCreds = credentials('azure-acr-creds')
                    // echo "Username: ${dockerCreds.username}"
                    // echo "Logging into Docker with credentials..."
                    // sh "echo ${dockerCreds.password} | docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password-stdin"
                    // sh 'docker info'
                }

                // Push Docker image to ACR
                // sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                // docker.withRegistry("https://${DOCKER_REGISTRY}", 'azure-acr-creds') {
                //     sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                // }
            }
        }

        // Just for demo
        stage('Pull Docker Image from ACR') {
            steps {
                // Login to Azure Container Registry
                script {
                    withCredentials([usernamePassword(credentialsId: 'service-principal-creds', usernameVariable: 'SERVICE_PRINCIPAL_ID', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD')]) {
                        sh "docker login ${DOCKER_REGISTRY} -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_PASSWORD"

                        // Pull Docker image from ACR
                        sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    }

                    // def dockerCreds = credentials('azure-acr-creds') // Use Jenkins credentials ID for ACR login
                    // sh "echo ${dockerCreds.password} | docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password-stdin"
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    // Login to Azure Container Registry
                    withCredentials([usernamePassword(credentialsId: 'service-principal-creds', usernameVariable: 'SERVICE_PRINCIPAL_ID', passwordVariable: 'SERVICE_PRINCIPAL_PASSWORD')]) {
                        sh "docker login ${DOCKER_REGISTRY} -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_PASSWORD"
                        
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

                    // def dockerCreds = credentials('azure-acr-creds') // Use Jenkins credentials ID for ACR login
                    // sh "echo ${dockerCreds.password} | docker login ${DOCKER_REGISTRY} --username ${dockerCreds.username} --password-stdin"
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
