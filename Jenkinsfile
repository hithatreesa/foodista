pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-cred'
        DOCKER_IMAGE          = 'hithatreesathomas/foodista'
        SONAR_SERVER_NAME     = 'sonarqube-env'
        SONAR_SCANNER_TOOL    = 'sonar-scanner'
        GIT_CREDENTIALS_ID    = 'github-cred'
        MANIFEST_BRANCH       = 'main'
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool "${SONAR_SCANNER_TOOL}"

                    withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=foodista-key \
                            -Dsonar.projectName=foodista-project \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/images/**,**/js/**,**/css/**,**/k8s/**
                        """
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${DOCKER_CREDENTIALS_ID}",
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                            docker build -t hithatreesathomas/foodista:${BUILD_NUMBER} .
                            docker tag hithatreesathomas/foodista:${BUILD_NUMBER} hithatreesathomas/foodista:latest

                            docker push hithatreesathomas/foodista:${BUILD_NUMBER}
                            docker push hithatreesathomas/foodista:latest

                            docker logout
                        '''
                    }
                }
            }
        }

        stage('Update Manifest') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${GIT_CREDENTIALS_ID}",
                        usernameVariable: 'GH_USER',
                        passwordVariable: 'GH_TOKEN'
                    )
                ]) {
                    sh '''
                        git config user.name "hithatreesa"
                        git config user.email "hithatreesa@gmail.com"

                        sed -i "s|image: .*|image: hithatreesathomas/foodista:${BUILD_NUMBER}|" k8s/deployment.yaml

                        git add k8s/deployment.yaml
                        git commit -m "Update Foodista image to ${BUILD_NUMBER} [skip ci]" || true

                        git push https://${GH_USER}:${GH_TOKEN}@github.com/hithatreesa/foodista.git HEAD:${MANIFEST_BRANCH}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Foodista pipeline completed successfully!'
        }

        failure {
            echo 'Foodista pipeline failed. Check the console output.'
        }
    }
}
