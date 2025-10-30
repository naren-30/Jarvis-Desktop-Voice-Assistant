pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "naren3005/jarvis:v1"
        DOCKER_CREDENTIALS = "docker"   // Jenkins credentials ID for DockerHub
        CONTAINER_NAME = "jarvis"
        APP_PORT = "8070"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/naren-30/Jarvis-Desktop-Voice-Assistant.git'
            }
        }

        stage('Set up Python Environment') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt || true
                '''
            }
        }

        stage('Lint Python Code') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install flake8
                    flake8 || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    echo "🧹 Cleaning up old container if it exists..."
                    docker rm -f $CONTAINER_NAME || true

                    echo "🚀 Running new container..."
                    docker run -d --name $CONTAINER_NAME -p $APP_PORT:$APP_PORT $DOCKER_IMAGE
                '''
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning workspace..."
            cleanWs()
        }
        success {
            echo "✅ Jarvis container is running on port ${APP_PORT}!"
        }
        failure {
            echo "❌ Build failed. Check logs for details!"
        }
    }
}
