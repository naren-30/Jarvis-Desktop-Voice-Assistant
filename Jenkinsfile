pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "naren3005"
        DOCKERHUB_REPO = "jarvis"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        IMAGE_NAME = "${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${IMAGE_TAG}"

        CREDENTIALS_DOCKER = "dockerhub-creds"
        CREDENTIALS_SSH = "swarm-ssh"
        SWARM_USER = "ubuntu"
        SWARM_HOST = "SWARM_MANAGER_IP"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Python & Install deps') {
            steps {
                sh '''
                  python3 -m venv venv
                  . venv/bin/activate
                  pip install --upgrade pip
                  pip install -r requirements.txt
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: CREDENTIALS_DOCKER, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                  sh '''
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker push ${IMAGE_NAME}
                    docker logout
                  '''
                }
            }
        }

        stage('Deploy to Swarm') {
            steps {
                sshagent(credentials: [CREDENTIALS_SSH]) {
                  sh """
                    scp -o StrictHostKeyChecking=no stack.yml ${SWARM_USER}@${SWARM_HOST}:/tmp/stack.yml
                    ssh -o StrictHostKeyChecking=no ${SWARM_USER}@${SWARM_HOST} \\
                      "docker pull ${IMAGE_NAME} && docker stack deploy -c /tmp/stack.yml jarvis_stack"
                  """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful: ${IMAGE_NAME}"
        }
        failure {
            echo "❌ Pipeline failed, check logs."
        }
        always {
            cleanWs()
        }
    }
}
