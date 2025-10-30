pipeline {
    agent any

    environment {
        APP_NAME = "mnc-insight-pulse"
        IMAGE_TAG = "dev-${BUILD_NUMBER}"
        CONTAINER_NAME = "mip_dev"
        NETWORK_NAME = "jenkins-net"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'devenv', url: 'https://github.com/junaid6468/mnc-insight-pulse.git', credentialsId: 'github-cred'
            }
        }

        stage('Verify Files') {
            steps {
                echo 'Listing workspace contents...'
                sh 'ls -al'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh '''
                docker build -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Run Dev Container & Smoke Test') {
            steps {
                script {
                    echo "Cleaning old containers..."
                    sh '''
                    docker rm -f ${CONTAINER_NAME} || true
                    docker network create ${NETWORK_NAME} || true
                    '''

                    echo "Starting new container..."
                    sh '''
                    docker run -d --name ${CONTAINER_NAME} \
                        --network ${NETWORK_NAME} \
                        -p 3000:80 \
                        ${APP_NAME}:${IMAGE_TAG}

                    echo "Waiting for app to boot..."
                    for i in {1..15}; do
                      HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${CONTAINER_NAME}:80 || true)
                      echo "Attempt $i - HTTP $HTTP_CODE"
                      if [ "$HTTP_CODE" = "200" ]; then
                        echo "Smoke test passed!"
                        exit 0
                      fi
                      sleep 3
                    done
                    echo "Smoke test failed - app not ready"
                    exit 1
                    '''
                }
            }
        }

        stage('Merge devenv → main and Push') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                echo 'Merging branch devenv → main...'
                sh '''
                git config user.name "Jenkins CI"
                git config user.email "jenkins@localhost"
                git checkout main
                git merge origin/devenv --no-edit
                git push origin main
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                echo 'Deploying container to production...'
                sh '''
                docker rm -f ${APP_NAME}_prod || true
                docker run -d --name ${APP_NAME}_prod -p 80:80 ${APP_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        always {
            echo "Cleaning up temporary containers..."
            sh 'docker rm -f ${CONTAINER_NAME} || true'
            echo "Pipeline complete. Production app at http://localhost"
        }
        failure {
            echo "❌ Build failed — check logs for details."
        }
        success {
            echo "✅ Build and deployment successful!"
        }
    }
}

