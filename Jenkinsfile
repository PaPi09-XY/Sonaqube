pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'sonar_server'  // Adjust this to your configured SonarQube installation
        NEXUS_URL = 'http://3.93.145.24:8081'  // Replace with your Nexus URL
        NEXUS_REPOSITORY = 'maven-snapshots'   // Replace with your Nexus repository name
        NEXUS_CREDENTIALS_ID = 'Nexus1'        // Replace with your Nexus credentials ID in Jenkins
        TOMCAT_CREDENTIALS_ID = 'tomcat9'      // Replace with your Tomcat credentials ID
        TOMCAT_URL = 'http://34.227.13.75:8080' // Replace with your Tomcat URL
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(SONARQUBE_ENV) {
                    sh 'cd MyWebApp && mvn sonar:sonar'
                }
            }
        }

        // Quality Gate check - ensures code quality thresholds are met
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {  // Timeout to avoid pipeline hanging
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Test') {
            steps {
                sh 'cd MyWebApp && mvn test'
            }
        }

        stage('Build') {
            steps {
                sh 'cd MyWebApp && mvn clean package'
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'MyWebApp', classifier: '', file: 'MyWebApp/target/mywebapp.war', type: 'war']], 
                    credentialsId: NEXUS_CREDENTIALS_ID, 
                    groupId: 'MyWebApp', 
                    nexusUrl: NEXUS_URL, 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: NEXUS_REPOSITORY, 
                    version: '1.0-SNAPSHOT'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: TOMCAT_CREDENTIALS_ID, path: '', url: TOMCAT_URL)], 
                       contextPath: 'webapp', 
                       war: '**/*.war'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Build failed. Please check the logs.'
        }
    }
}
