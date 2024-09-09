pipeline {
    agent any

    tools {
        maven 'Maven_3.8.1'  // Adjust this to your configured Maven installation
        jdk 'JDK_11'          // Adjust this to your configured JDK installation
    }

    environment {
        SONARQUBE_ENV = 'Sonar_server'  // Adjust this to your configured SonarQube installation
        NEXUS_URL = 'http://3.93.145.24:8081'  // Replace with your Nexus URL
        NEXUS_REPOSITORY = 'maven-snapshots'          // Replace with your Nexus repository name
        NEXUS_CREDENTIALS_ID = 'Nexus1'   // Replace with your Nexus credentials ID in Jenkins
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
                    nexusArtifactUploader artifacts: [[artifactId: 'MyWebApp', classifier: '', file: 'MyWebApp/target/mywebapp.war', type: 'war']], credentialsId: 'Nexus1', groupId: 'MyWebApp', nexusUrl: '3.93.145.24:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOT'
            
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat9', path: '', url: 'http://34.227.13.75:8080')], contextPath: 'webapp', war: '**/*.war'
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
