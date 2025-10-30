pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        IMAGE_NAME = "naren3005/jarvis"
        IMAGE_TAG = "v1.${BUILD_NUMBER}"
        SWARM_USER = "ubuntu"
        SWARM_HOST = "your-swarm-manager-ip"
        SSH_CREDS = "swarm-ssh"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📦 Checking out source code..."
                checkout scm
            }
        }

        stage('Setup Python Environment') {
            steps {
                echo "🐍 Setting up virtual environment..."
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Lint Code') {
            steps {
                echo "🔍 Running lint check..."
                sh '''
                . venv/bin/activate
                pip install flake8
                flake8 || true
                '''
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Running test suite..."
                sh '''
                . venv/bin/activate
                pip install pytest
                mkdir -p test-results
                pytest --junitxml=test-results/results.xml || true
                '''
            }
            post {
                always {
                    junit 'test-results/results.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "🚀 Pushing image to Docker Hub..."
                sh '''
                echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                docker push $IMAGE_NAME:$IMAGE_TAG
                docker logout
                '''
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                echo "⚓ Deploying to Swarm..."
                sshagent([SSH_CREDS]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $SWARM_USER@$SWARM_HOST '
                        echo "📥 Pulling latest image..."
                        docker login -u $DOCKERHUB_CREDENTIALS_USR -p $DOCKERHUB_CREDENTIALS_PSW
                        docker pull $IMAGE_NAME:$IMAGE_TAG
                        echo "🧹 Removing old service (if any)..."
                        docker service rm jarvis || true
                        echo "🚢 Creating new Swarm service..."
                        docker service create \\
                            --name jarvis \\
                            --with-registry-auth \\
                            --publish 8070:8070 \\
                            --replicas 1 \\
                            $IMAGE_NAME:$IMAGE_TAG
                    '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Jarvis successfully deployed on Docker Swarm!"
        }
        failure {
            echo "❌ Build failed. Check logs for details!"
        }
        always {
            cleanWs()
        }
    }
}
