
pipeline {
    agent any
    parameters {
        choice(name: 'Environment', choices: ['...', 'demo', 'hotfix'], description: '')
    }
    environment {
        PATH = "${PATH}:${getTerraformPath()}"
        profile='latest'
        region='us-west-2'
    }
    stages {
        stage ('Clean Workspace') {
            steps {
                deleteDir()
            }
        }
        
        stage('Get Code') {
            steps {
                git branch: 'develop', credentialsId: 'a1ea7821-5135-4059-b403-484f839b37d4', poll: false, url: 'git@gitlab.com:clienthq/Moscu/client-infra.git'
            }
        }

        stage ('Get apigateway information'){
            steps {
                script{
                    dir ('Terraform/OnDemand/'){
                        sh "ansible-playbook -i latest_hosts delete_apigateway.yml -e env='$params.Environment'"
                    }
                    def INPUT_PARAMS = input message: 'Delete ApiGateway Stack?', ok: 'Continue!',
                            parameters: [choice(name: 'DELETE_APIGATEWAY', choices: ['yes', 'no'].join('\n'), description: 'Changes cannot be undone!')]
                    env.DELETE_APIGATEWAY = INPUT_PARAMS
                }
            }
        }
        stage("Deleting apigateway.") {
            when {expression {env.DELETE_APIGATEWAY == 'yes'}}
            steps {
                script{
                    dir ('Terraform/OnDemand/'){
                        sh "ansible-playbook -i latest_hosts delete_apigateway.yml -e env='$params.Environment' -e delete_action=true"
                    }
                }
            }
        }
        stage("Skipping deleting apigateway.") {
            when {expression {env.DELETE_APIGATEWAY != 'yes'}}
            steps {
                script {
                  sh "echo 'Your response: ${env.DELETE_APIGATEWAY}'"
                }
            }
        }

        stage ('Get stack information'){
            steps {
                script{
                    dir ('Terraform/OnDemand/'){
                        sh label: 'Show stack information', script: "ansible-playbook -i latest_hosts delete_services_stack.yml -e env='$params.Environment'"
                    }
                    def INPUT_PARAMS = input message: 'Delete CloudFormation Stack?', ok: 'Continue!',
                            parameters: [choice(name: 'DELETE_CF_STACK', choices: ['yes', 'no'].join('\n'), description: 'Changes cannot be undone!')]                    
                    env.DELETE_CF_STACK = INPUT_PARAMS                    
                }
            }
        }
        stage("Deleting cloudformation stack.") {
            when {expression {env.DELETE_CF_STACK == 'yes'}}
            steps {
                script{
                    dir ('Terraform/OnDemand/'){
                        sh label: 'Delete stack resources', script: "ansible-playbook -i latest_hosts delete_services_stack.yml -e env='$params.Environment' -e delete_action=true"
                    }
                }
            }
        }
        stage("Skipping deleting cloudformation stack.") {
            when {expression {env.DELETE_CF_STACK != 'yes'}}
            steps {
                script {
                  sh "echo 'Your response: ${env.DELETE_CF_STACK}'"
                }
            }
        }

        stage ('Run terraform plan'){
            steps {
                dir ('Terraform/OnDemand/'){
                    withCredentials([usernamePassword(credentialsId: 'dustin_gitlab_read_only_pat_token', passwordVariable: 'gitlab_token', usernameVariable: 'user')]) {
                        withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                            sh label: 'Destroy plan - React', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'reactssr-latest' -e terraform_destroy=false"
                            sh label: 'Destroy plan - appcAPI', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'appcapi-latest' -e terraform_destroy=false"
                            sh label: 'Destroy plan - appUI', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'appui-latest' -e terraform_destroy=false"
                            sh label: 'Destroy plan - appd', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'appd-latest' -e terraform_destroy=false"
                        }
                    }
                }
                script {
                    def INPUT_PARAMS = input message: 'Delete Terraform Resources?', ok: 'Continue!',
                            parameters: [choice(name: 'DELETE_TF_RESOURCES', choices: ['yes', 'no'].join('\n'), description: 'Changes cannot be undone!')]
                    sh "echo ${INPUT_PARAMS}"
                    env.DELETE_TF_RESOURCES = INPUT_PARAMS
                }
            }
        }

        stage("Deleting Terraform resources.") {
            when {expression {env.DELETE_TF_RESOURCES == 'yes'}}
            steps {
                script {
                    dir ('Terraform/OnDemand/'){
                        withCredentials([usernamePassword(credentialsId: 'dustin_gitlab_read_only_pat_token', passwordVariable: 'gitlab_token', usernameVariable: 'user')]) {
                            withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                                sh label: 'Destroy Apply - React', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'reactssr-latest' -e terraform_destroy=true -e terraform_plan=false"
                                sh label: 'Destroy Apply - appcAPI', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'appcapi-latest' -e terraform_destroy=true -e terraform_plan=false"
                                sh label: 'Destroy Apply - appUI', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'appui-latest' -e terraform_destroy=true -e terraform_plan=false"
                                sh label: 'Destroy Apply - appd', script: "./delete_ondemand_latest -e env='$params.Environment' -l 'appd-latest' -e terraform_destroy=true -e terraform_plan=false"
                            }
                        }
                    }
                }
            }
        }

        stage("Skipping deleting Terraform resources.") {
            when {expression {env.DELETE_TF_RESOURCES != 'yes'}}
            steps {
                script {
                  sh "echo 'Your response: ${env.DELETE_TF_RESOURCES}'"
                }
            }
        }

        stage ('Check secret manager to delete'){
            steps {
                dir ('Terraform/OnDemand/'){
                    sh label: 'Get remaining secrets', script: "ansible-playbook -i latest_hosts delete_secret_no_recovery.yml -e env='$params.Environment' -e delete_action=false"
                }
                script {
                    def INPUT_PARAMS = input message: 'Delete Secret Manager Resources?', ok: 'Continue!',
                            parameters: [choice(name: 'DELETE_TF_RESOURCES', choices: ['yes', 'no'].join('\n'), description: 'Changes cannot be undone!')]
                    sh "echo ${INPUT_PARAMS}"
                    env.DELETE_SSM_RESOURCES = INPUT_PARAMS
                }
            }
        }

        stage("Deleting Secret Manager resources.") {
            when {expression {env.DELETE_SSM_RESOURCES == 'yes'}}
            steps {
                dir ('Terraform/OnDemand/'){
                    sh label: 'Remove remaining secrets', script: "ansible-playbook -i latest_hosts delete_secret_no_recovery.yml -e env='$params.Environment' -e delete_action=true"
                }
            }
        }
        stage("Skipping deleting Secret Manager resources.") {
            when {expression {env.DELETE_SSM_RESOURCES != 'yes'}}
            steps {
                script {
                  sh "echo 'Your response: ${env.DELETE_SSM_RESOURCES}'"
                }
            }
        }
    }
}

def getTerraformPath() {
    def tfHome = tool name: 'Terraform-12.13', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
    return tfHome
}

