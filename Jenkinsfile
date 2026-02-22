pipeline {
    agent any

    tools {
        jdk 'jdk-21'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                bat 'gradlew.bat clean build'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar') {
                    bat 'gradlew.bat sonar'
                }
            }
        }
    }
}
