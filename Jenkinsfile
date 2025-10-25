pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub') // DockerHub username + token
        IMAGE_NAME = "naren3005/jarvis"
        IMAGE_TAG = "v1"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "🔄 Checking out code..."
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "📦 Setting up Python virtual environment..."
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Lint Check') {
            steps {
                echo "📝 Running lint checks with flake8..."
                sh '''
                    . venv/bin/activate
                    pip install flake8
                    flake8 || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh '''
                    set -x
                    docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "🚀 Pushing Docker image to DockerHub..."
                sh '''
                    set -x
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                    docker push $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                echo "⚙️ Deploying Docker service to Swarm..."
                sh '''
                    set -x
                    docker login -u "$DOCKERHUB_CREDENTIALS_USR" -p "$DOCKERHUB_CREDENTIALS_PSW"
                    
                    # Remove existing service if it exists
                    docker service rm jarvis || true

                    # Deploy new service
                    docker service create \
                        --name jarvis \
                        --with-registry-auth \
                        --publish 8080:8080 \
                        $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment Successful! Jarvis is ready to serve your commands!"
        }
        failure {
            echo "💥 Deployment Failed! Jarvis is sleeping on the job..."
        }
    }
}
