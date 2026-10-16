pipeline {
    agent any

    tools {
        jdk 'JDK17'
    }

    environment {
        DOCKER = 'C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe'
        CI_DB_CONTAINER = 'todo-ci-mysql'
        CI_DB_PASSWORD = credentials('ci-db-password')
        BACKEND_IMAGE = 'piyushkeshri22/todo-backend'
        FRONTEND_IMAGE = 'piyushkeshri22/todo-frontend'
        EC2_HOST = '15.206.73.178'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Start CI Database') {
            steps {
                bat '''
                    "%DOCKER%" rm -f "%CI_DB_CONTAINER%" 2>NUL
                    "%DOCKER%" run -d --name "%CI_DB_CONTAINER%" ^
                      -e MYSQL_ROOT_PASSWORD=%CI_DB_PASSWORD% ^
                      -e MYSQL_DATABASE=todo_db ^
                      -p 127.0.0.1:3307:3306 ^
                      mysql:8.0
                '''

                script {
                    int retries = 30
                    boolean ready = false

                    for (int i = 0; i < retries; i++) {
                        int result = bat(
                            returnStatus: true,
                            script: '"%DOCKER%" exec "%CI_DB_CONTAINER%" mysqladmin ping -h 127.0.0.1 -uroot -p%CI_DB_PASSWORD% --silent'
                        )

                        if (result == 0) {
                            ready = true
                            break
                        }

                        sleep(time: 5, unit: 'SECONDS')
                    }

                    if (!ready) {
                        error('CI MySQL database did not become ready.')
                    }
                }
            }
        }

        stage('Backend Build and Test') {
            steps {
                dir('Backend/todo-summary-assistant') {
                    bat '''
                        call mvnw.cmd -B clean verify ^
                          -Dspring.datasource.url=jdbc:mysql://127.0.0.1:3307/todo_db ^
                          -Dspring.datasource.username=root ^
                          -Dspring.datasource.password=%CI_DB_PASSWORD%
                    '''
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
                bat '"%DOCKER%" build -t "%BACKEND_IMAGE%:%BUILD_NUMBER%" Backend/todo-summary-assistant'
                bat '"%DOCKER%" build -t "%FRONTEND_IMAGE%:%BUILD_NUMBER%" Frontend/todo'
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    bat '''
                        powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$env:DH_TOKEN | & $env:DOCKER login --username $env:DH_USER --password-stdin"
                        if errorlevel 1 exit /b 1

                        "%DOCKER%" push "%BACKEND_IMAGE%:%BUILD_NUMBER%"
                        if errorlevel 1 exit /b 1

                        "%DOCKER%" push "%FRONTEND_IMAGE%:%BUILD_NUMBER%"
                        if errorlevel 1 exit /b 1

                        "%DOCKER%" logout
                    '''
                }
            }
        }
        stage('Deploy to EC2 and Verify') {
            steps {
            withCredentials([
            sshUserPrivateKey(
                credentialsId: 'ec2-ssh-key',
                keyFileVariable: 'EC2_KEY',
                usernameVariable: 'EC2_USER'
            )
            ]) {
            bat '''
                set "SSH=C:\\Windows\\System32\\OpenSSH\\ssh.exe"

                if not exist "%SSH%" (
                    echo ERROR: Windows OpenSSH client not found.
                    exit /b 1
                )

                "%SSH%" -i "%EC2_KEY%" ^
                  -o BatchMode=yes ^
                  -o StrictHostKeyChecking=accept-new ^
                  "%EC2_USER%@%EC2_HOST%" ^
                  "bash -s -- %BUILD_NUMBER%" < deploy/deploy-ec2.sh

                if errorlevel 1 exit /b 1
            '''
                }
            }
        }
    }

    post {
        always {
            bat '"%DOCKER%" rm -f "%CI_DB_CONTAINER%" 2>NUL'
            echo 'Pipeline execution finished.'
        }
        success {
            echo 'CI pipeline completed successfully.'
        }
        failure {
            echo 'CI pipeline failed. Review the stage logs.'
        }
    }
}
