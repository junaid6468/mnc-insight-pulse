pipeline {
  agent any

  environment {
    // ====== Environment Variables ======
    IMAGE_NAME      = "mnc-insight-pulse"                 // Name of your app image
    DOCKERHUB_USER  = "junaid6468"                        // Your Docker Hub username
    DOCKERHUB_CRED  = "dockerhub-token"                   // Jenkins credential ID (Secret Text)
    APP_CONTAINER   = "mnc-insight-pulse-container"       // Container name for deployment
    HOST_PORT       = "3000"                              // Host port to expose (maps to container:80)
    PATH            = "/usr/local/bin:${PATH}"            // Ensure Node & Docker paths are included
  }

  stages {

    // ====== 1️⃣ Preparation Stage ======
    stage('Prepare') {
      steps {
        script {
          echo "🔹 Checking environment setup..."
          echo "Branch Name: ${env.BRANCH_NAME}"
          sh 'node -v || true'
          sh 'npm -v || true'
          sh 'docker -v || true'
        }
      }
    }

    // ====== 2️⃣ Install & Build Stage ======
    stage('Install & Build') {
      steps {
        echo "🔹 Installing dependencies and building the frontend..."
        sh '''
          npm ci
          npm run build
        '''
      }
    }

    // ====== 3️⃣ Run Tests Stage ======
    stage('Run Tests') {
      steps {
        echo "🔹 Running tests (if defined in package.json)..."
        sh '''
          if grep -q '"test"' package.json; then
            npm run test -- --watchAll=false || exit 1
          else
            echo "No test script defined — skipping tests."
          fi
        '''
      }
    }

    // ====== 4️⃣ Build Docker Image Stage ======
    stage('Build Docker Image') {
      steps {
        echo "🔹 Building Docker image..."
        sh '''
          docker build -t ${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER} .
        '''
      }
    }

    // ====== 5️⃣ Push Docker Image to Docker Hub ======
    stage('Push to Docker Hub') {
      steps {
        echo "🔹 Pushing image to Docker Hub..."
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

    // ====== 6️⃣ Deploy Container Stage ======
    stage('Deploy (Replace Existing Container)') {
      steps {
        echo "🔹 Deploying new container version..."
        sh '''
          # Stop and remove existing container if it exists
          if docker ps -q -f name=${APP_CONTAINER} | grep -q .; then
            echo "Stopping and removing existing container..."
            docker stop ${APP_CONTAINER} || true
            docker rm ${APP_CONTAINER} || true
          fi

          # Run new container from latest pushed image
          echo "Starting new container..."
          docker run -d --name ${APP_CONTAINER} -p ${HOST_PORT}:80 ${DOCKERHUB_USER}/${IMAGE_NAME}:${BRANCH_NAME}-${BUILD_NUMBER}
        '''
      }
    }
  }

  // ====== 7️⃣ Post Build Actions ======
  post {
    success {
      echo "✅ Deployment SUCCESS!"
      echo "🌐 Application URL: http://<your-server-ip>:${HOST_PORT}"
    }
    failure {
      echo "❌ Pipeline FAILED — check Jenkins console output for details."
    }
    always {
      echo "🔹 Pipeline finished at: ${new Date()}"
    }
  }
}
