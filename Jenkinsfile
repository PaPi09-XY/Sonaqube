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
                timeout(time: 3, unit: 'MINUTES') {  // Timeout to avoid pipeline hanging
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }


        stage('Push to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'MyWebApp', classifier: '', file: 'MyWebApp/target/mywebapp.war', type: 'war']],
                    credentialsId: 'Nexus1',
                    groupId: 'MyWebApp',
                    nexusUrl: '52.87.237.16:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'maven-snapshots',
                    version: '1.0-SNAPSHOT'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat9', path: '', url: 'http://3.82.198.42:8080')], contextPath: 'webapp', war: '**/*.war'
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
