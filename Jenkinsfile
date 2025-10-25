pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/naren-30/Jarvis-Desktop-Voice-Assistant.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Lint Check') {
            steps {
                sh 'flake8 || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t jarvis:latest .'
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                sh '''
                docker service rm jarvis || true
                docker service create --name jarvis --publish 8080:8080 jarvis:latest
                '''
            }
        }
    }
}

