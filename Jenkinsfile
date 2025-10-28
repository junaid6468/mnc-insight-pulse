pipeline {
  agent any

  environment {
    IMAGE_NAME = "mnc-insight-pulse"
    DOCKERHUB_USER = "junaid6468"        // <- change if different
    DOCKERHUB_CRED = "dockerhub-token"  // <- Jenkins credential ID (secret text)
    APP_CONTAINER = "mnc-insight-pulse-container"
    HOST_PORT = "3000"                   // host port to expose (avoid 8080)
  }

  stages {
    stage('Prepare') {
      steps {
        script {
          echo "Branch: ${env.BRANCH_NAME}"
          sh 'node -v || true'
        }
      }
    }

    stage('Install & Build') {
      steps {
        sh '''
          npm ci
          npm run build
        '''
      }
    }

    stage('Run Tests') {
      steps {
        sh '''
          # run tests if present, fail pipeline on test failures
          if grep -q "\"test\"" package.json; then
            npm run test -- --watchAll=false || exit 1
          else
            echo "No test script defined - skipping tests"
          fi
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t ${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER} .
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([string(credentialsId: "${DOCKERHUB_CRED}", variable: 'DOCKERHUB_TOKEN')]) {
          sh '''
            echo "$DOCKERHUB_TOKEN" | docker login -u ${DOCKERHUB_USER} --password-stdin
            docker tag ${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER} ${DOCKERHUB_USER}/${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER}
            docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER}
            docker logout
          '''
        }
      }
    }

    stage('Deploy (replace)') {
      steps {
        sh '''
          # stop & remove existing container (if any), then run new one
          if docker ps -q -f name=${APP_CONTAINER} | grep -q .; then
            docker stop ${APP_CONTAINER} || true
            docker rm ${APP_CONTAINER} || true
          fi
          docker run -d --name ${APP_CONTAINER} -p ${HOST_PORT}:80 ${DOCKERHUB_USER}/${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER}
        '''
      }
    }
  }

  post {
    success {
      echo "Deployment SUCCESS — App: http://<server-ip>:${HOST_PORT}"
    }
    failure {
      echo "Pipeline FAILED — check console output"
    }
  }
}

