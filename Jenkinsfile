pipeline {
  agent any

  environment {
    SONAR_HOST_URL = 'http://localhost:9000'
  }

  stages {
    stage('SonarQube') {
      steps {
        withCredentials([string(credentialsId: 'sonar-backend-token', variable: 'SONAR_TOKEN')]) {
          withSonarQubeEnv('SonarQube') {
            sh '''
              mvn clean verify sonar:sonar \
              -Dsonar.projectKey=project-tracker-backend \
              -Dsonar.login=$SONAR_TOKEN
            '''
          }
        }
      }
    }
  }
}
