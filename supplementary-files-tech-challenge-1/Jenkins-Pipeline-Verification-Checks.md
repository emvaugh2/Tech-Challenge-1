

# GitHub PAT Token Verification


pipeline {
    agent any
    stages {
        stage('Git Test') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-pat',
                    url: 'https://github.com/YOUR_USERNAME/YOUR_REPO.git'
            }
        }
    }
}



# AWS Credentials Verification

pipeline {
    agent any
    stages {
        stage('AWS Test') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-creds']
                ]) {
                    sh 'aws sts get-caller-identity'
                }
            }
        }
    }
}

# Docker Service Verification

pipeline {
    agent any
    stages {
        stage('Docker Test') {
            steps {
                sh 'docker ps'
            }
        }
    }
}