pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                sh 'cd MyWebApp && mvn clean install'
            }
        }

 // Verify WAR file existence
        stage('Verify WAR File') {
            steps {
                sh 'ls -l MyWebApp/target'
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
                script {
                     if (fileExists('MyWebApp/target/MyWebApp.war'))
                {
                nexusArtifactUploader artifacts: [[artifactId: 'MyWebApp', classifier: '', file: 'MyWebApp/target/MyWebApp.war', type: 'war']], credentialsId: 'Nexus1', groupId: 'MyWebApp', nexusUrl: 'ec2-184-72-102-3.compute-1.amazonaws.com:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOTS'
            } else {
                        error('WAR file not found, skipping Nexus upload.')
                    }
                }
            }
        }


        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat9', path: '', url: 'http://54.172.10.52:8080')], contextPath: 'webapp', war: '**/*.war'
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
