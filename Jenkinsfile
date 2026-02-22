pipeline {
    agent any

    tools {
        nodejs 'node-24'
    }

    environment {
        SERVER = '100.53.232.94'   
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/junaid6468/mnc-insight-pulse.git'
            }
        }

        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2-key',
                    keyFileVariable: 'KEY'
                )]) {

                    sh """
                        # Sync to home directory first
                rsync -avz --delete \
                  -e "ssh -i $KEY -o StrictHostKeyChecking=no" \
                  dist/ ubuntu@100.53.232.94:/home/ubuntu/dist/

                # Move with sudo on server
                ssh -i "$KEY" -o StrictHostKeyChecking=no ubuntu@100.53.232.94 "
                    sudo rm -rf /var/www/html/*
                    sudo cp -r /home/ubuntu/dist/* /var/www/html/
                    sudo systemctl restart nginx
                "
                    """
                }
            }
        }
    }
}
