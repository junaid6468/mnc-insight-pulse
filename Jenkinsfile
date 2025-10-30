pipeline {
    agent any

    environment {
        APP_NAME = "mnc-insight-pulse"
        IMAGE_NAME = "mnc-insight-pulse:latest"
        CONTAINER_NAME = "mnc-insight-pulse-container"
        PORT = "8081"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from repository..."
                git branch: 'devenv', url: 'https://github.com/junaid6468/mnc-insight-pulse.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Stop Old Container') {
            steps {
                echo "Stopping old container if running..."
                // This stops and removes the old container if it exists
                sh '''
                    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                    fi
                '''
            }
        }

        stage('Run New Container') {
            steps {
                echo "Running new container on port $PORT..."
                sh 'docker run -d --name $CONTAINER_NAME -p $PORT:80 $IMAGE_NAME'
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying if the container is running..."
                sh '''
                    echo "Running containers:"
                    docker ps
                    echo "Testing access to the deployed app..."
                    sleep 5
                    curl -I http://localhost:$PORT || echo "App not reachable yet!"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Application is running on port $PORT."
        }
        failure {
            echo "❌ Build failed! Please check the Jenkins logs for errors."
        }
    }
}

