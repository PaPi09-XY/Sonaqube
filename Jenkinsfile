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
                waitForQualityGate abortPipeline: true
            }
        }


        stage('Push to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'MyWebApp', classifier: '', file: 'MyWebApp/target/MyWebApp.war', type: 'war']], credentialsId: 'Nexus2', groupId: 'MyWebApp', nexusUrl: 'ec2-3-88-43-189.compute-1.amazonaws.com:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOT'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat9', path: '', url: 'http://54.144.240.202:8080')], contextPath: 'webapp', war: '**/*.war'
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
