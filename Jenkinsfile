pipeline {
    agent any

    environment {
        IMAGE_NAME = "myapp-${env.BRANCH_NAME}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/junaid6468/mnc-insight-pulse.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME .'
                }
            }
        }

        stage('Run Container') {
            steps {
                script {
                    // Stop any existing container
                    sh 'docker rm -f $IMAGE_NAME || true'
                    // Run new one
                    sh 'docker run -d -p 5000:5000 --name $IMAGE_NAME $IMAGE_NAME'
                }
            }
        }
    }
}
