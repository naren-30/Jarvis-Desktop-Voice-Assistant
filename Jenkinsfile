pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "naren3005/jarvis:v1"
        DOCKER_CREDENTIALS = "docker"     // Jenkins credentials ID for DockerHub
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

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                sh '''
                    docker swarm init || true
                    docker service rm jarvis || true
                    docker service create --name jarvis -p 8070:8070 --replicas 3 $DOCKER_IMAGE
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
            echo "✅ Build and deployment successful!"
        }
        failure {
            echo "❌ Build failed. Check logs for details!"
        }
    }
}
