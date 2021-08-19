// https://github.com/zhangpanqin/fly-devops-lib
// @Library('fly-devops-lib@master') _
// serviceDeployPipeline([serviceName:"order-manage-service"])
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "${env.GIT_BRANCH}"
                echo "${env.GIT_LOCAL_BRANCH}"
            }
        }
    }
}