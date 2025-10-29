pipeline {
    agent any

    environment {
        IMAGE = "mnc-insight-pulse"
        DEV_CONTAINER = "mip_dev"
        PROD_CONTAINER = "mip_prod"
        REGISTRY = ""  // Empty for local; add 'yourdockerhub/' if pushing
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/devenv']],
                    userRemoteConfigs: [[url: 'https://github.com/junaid6468/mnc-insight-pulse.git']]
                ])
            }
        }

        stage('Verify Files') {
            steps {
                echo "Listing workspace contents..."
                sh 'ls -al'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE}:dev-${env.BUILD_ID} ."
            }
        }

        stage('Run Dev Container & Smoke Test') {
            steps {
                sh """
                    # Stop/remove previous if any
                    docker rm -f ${DEV_CONTAINER} || true
                    docker run -d --name ${DEV_CONTAINER} -p 3000:80 ${IMAGE}:dev-${env.BUILD_ID}
                    # Wait and test (up to 30s)
                    echo "Waiting for app to boot..."
                    for i in \$(seq 1 15); do
                        HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
                        echo "Attempt \$i - HTTP \$HTTP_CODE"
                        if [ "\$HTTP_CODE" = "200" ]; then
                            exit 0
                        fi
                        sleep 2
                    done
                    echo "Smoke test failed - app not ready"
                    exit 1
                """
            }
        }

        stage('Merge devenv -> main and Push') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    sh """
                        git config user.email "jenkins@local"
                        git config user.name "${GIT_USER}"
                        git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/junaid6468/mnc-insight-pulse.git
                        git fetch origin
                        git checkout main || git checkout -b main origin/main
                        git merge --no-ff origin/devenv -m "Automated merge from devenv by Jenkins build #${env.BUILD_ID}"
                        git push origin main
                    """
                }
            }
        }

        stage('Deploy to Production') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh """
                    # Tag and deploy prod
                    docker tag ${IMAGE}:dev-${env.BUILD_ID} ${IMAGE}:latest
                    docker rm -f ${PROD_CONTAINER} || true
                    docker run -d --name ${PROD_CONTAINER} -p 80:80 ${IMAGE}:latest
                """
            }
        }
    }

    post {
        always {
            sh "docker rm -f ${DEV_CONTAINER} || true"
            echo "Pipeline complete. Prod app at http://localhost (if deployed)."
        }
        failure {
            echo "Build failed—check logs for details."
        }
        success {
            echo "Success! Merged to main and deployed prod container."
        }
    }
}
