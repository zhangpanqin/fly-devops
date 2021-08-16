pipeline {
    agent none
    stages {
        stage('build') {
            agent {
                docker { image 'gradle:jdk11' }
            }
            steps {
                sh 'pwd'
                sh 'gradle --version'
                retry(3) {
                    sh 'echo retry'
                }

                timeout(time: 3, unit: 'MINUTES') {
                    sh 'echo timeout'
                }
            }
        }
    }
    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}