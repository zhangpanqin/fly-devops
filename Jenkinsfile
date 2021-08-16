pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh 'pwd'
                sh './gradlew --version'
                retry(3) {
                    sh 'echo retry'
                }

                timeout(time: 3, unit: 'MINUTES') {
                    sh 'echo timeout'
                }
            }
        }
    }
}