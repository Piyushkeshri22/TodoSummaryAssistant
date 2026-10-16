pipeline {
    agent any

    tools {
        jdk 'JDK17'
    }

    environment {
        DOCKER = 'C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Source code is checked out from the configured repository.'
                checkout scm
            }
        }

        stage('Backend Build and Test') {
            steps {
                dir('Backend/todo-summary-assistant') {
                    bat 'call mvnw.cmd -B clean verify'
                }
            }
        }

        stage('Frontend Build') {
            steps {
                dir('Frontend/todo') {
                    bat 'call npm.cmd ci'
                    bat 'call npm.cmd run build'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                bat '"%DOCKER%" build -t todo-backend:%BUILD_NUMBER% Backend/todo-summary-assistant'
                bat '"%DOCKER%" build -t todo-frontend:%BUILD_NUMBER% Frontend/todo'
            }
        }
    }

    post {
        success {
            echo 'CI pipeline completed successfully.'
        }
        failure {
            echo 'CI pipeline failed. Review the stage logs.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
