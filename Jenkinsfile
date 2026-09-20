pipeline {
    agent any
    environment {
        // This references a 'Username with password' credential created inside your Jenkins UI
        DOCKER_CREDS = credentials('docker-hub-creds') 
        DOCKER_USER  = 'namodharani'
        DEV_REPO     = 'devops-build-dev'
        PROD_REPO    = 'devops-build-prod'
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                // Builds the container image natively on the server architecture
                sh "docker build -t ${DOCKER_USER}/${DEV_REPO}:${IMAGE_TAG} -t ${DOCKER_USER}/${PROD_REPO}:${IMAGE_TAG} ."
            }
        }
        stage('Docker Hub Routing & Push') {
            steps {
                // Log into Docker Hub securely using the automated credentials environment variables
                sh "echo \$DOCKER_CREDS_PSW | docker login -u \$DOCKER_CREDS_USR --password-stdin"
                
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        echo "🌿 Branch 'dev' matched: Uploading to Public Development Repository..."
                        sh "docker push ${DOCKER_USER}/${DEV_REPO}:${IMAGE_TAG}"
                    } else if (env.BRANCH_NAME == 'main') {
                        echo "🚀 Branch 'main' matched: Uploading to Private Production Repository..."
                        sh "docker push ${DOCKER_USER}/${PROD_REPO}:${IMAGE_TAG}"
                    }
                }
            }
        }
    }
    post {
        always {
            // Cleans temporary login credentials from the agent environment after execution
            sh "docker logout"
        }
    }
}
