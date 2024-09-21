pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                sh 'cd MyWebApp && mvn clean install'
            }
        }

        stage('Test') {
            steps {
                sh 'cd MyWebApp && mvn test'
            }
        }

        stage('Code Quality Scan') {
            steps {
                withSonarQubeEnv('sonar_server') {
                    sh 'mvn -f MyWebApp/pom.xml sonar:sonar'
                }
            }
        }

        // Quality Gate check - ensures code quality thresholds are met
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Push to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'MyWebApp', classifier: '', file: 'MyWebApp/target/MyWebApp.war', type: 'war']], credentialsId: 'Nexus1', groupId: 'com.mycompany.mywebapp', nexusUrl: 'http://ec2-54-235-228-39.compute-1.amazonaws.com:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOT'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat', path: '', url: 'http://54.210.135.165:8080')], contextPath: 'webapp', war: '**/*.war'
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
