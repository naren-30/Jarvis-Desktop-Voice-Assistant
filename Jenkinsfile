pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        IMAGE_NAME = "naren3005/jarvis"
        IMAGE_TAG = "v1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
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
                sh '''
                . venv/bin/activate
                pip install flake8
                flake8 || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                docker push $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                sh '''
                docker login -u "$DOCKERHUB_CREDENTIALS_USR" -p "$DOCKERHUB_CREDENTIALS_PSW"
                
                docker service rm jarvis || true
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
