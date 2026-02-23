pipeline {
    agent any

    tools {
        jdk 'jdk-21'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/MDhanushraju/Project-traker-backend.git',
                    credentialsId: 'github-token'
            }
        }

        stage('Build') {
            steps {
                bat 'gradlew clean build -x test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarQube') {
                    bat 'gradlew sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
