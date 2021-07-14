
pipeline {
    agent any
    parameters {
        choice(name: 'Environment', choices: ['...', 'demo', 'hotfix'], description: '')
    }
    environment {
        PATH = "${PATH}:${getTerraformPath()}"
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

         stage ('Deploy demo environment'){
            when {expression {params.Environment == 'demo'}}

            steps{
                dir ('Terraform/OnDemand/'){
                    withCredentials([usernamePassword(credentialsId: 'dustin_gitlab_read_only_pat_token', passwordVariable: 'gitlab_token', usernameVariable: 'user')]) {
                        withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                            sh "./deploy_ondemand_latest -e env='demo' -e gitlab_pat_token=${gitlab_token} -e key_pair=${keyfile}"
                        }
                    }
                }
            }
        }
        stage ('Sync appd DB demo environment'){
            when {expression {params.Environment == 'demo'}}

            steps{
                dir ('Terraform/OnDemand/roles/appd/files'){
                    sh "sh syncdb.sh Staging demo latest"
                }
            }
        }
        stage ('Update appd demo ECS'){
            when {expression {params.Environment == 'demo'}}

            steps{
                dir ('Terraform/OnDemand/'){
                    withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                        sh "ansible-playbook ondemand_appd_deploy_container.yml -i latest_hosts -l 'appd-latest' -e env='demo' -e key_pair=${keyfile}"
                    }
                }
            }
        }

        stage ('Build and Deploy demo containers'){
            when {expression {params.Environment == 'demo'}}

            steps{
                dir ('Terraform/OnDemand/'){
                    withCredentials([usernamePassword(credentialsId: 'dustin_gitlab_read_only_pat_token', passwordVariable: 'gitlab_token', usernameVariable: 'user')]) {
                        withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                            sh "ansible-playbook ondemand_ecs.yml -i latest_hosts  -e env='demo' -e gitlab_pat_token=${gitlab_token}"
                        }
                    }
                }
            }
        }
        // START HERE
        stage ('Deploy hotfix environment'){
            when {expression {params.Environment == 'hotfix'}}

            steps{
                dir ('Terraform/OnDemand/'){
                    withCredentials([usernamePassword(credentialsId: 'dustin_gitlab_read_only_pat_token', passwordVariable: 'gitlab_token', usernameVariable: 'user')]) {
                        withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                            sh "./deploy_ondemand_latest -e env='hotfix' -e gitlab_pat_token=${gitlab_token} -e key_pair=${keyfile}"
                        }
                    }
                }
            }
        }
        stage ('Sync appd DB'){
            when {expression {params.Environment == 'hotfix'}}

            steps{
                dir ('Terraform/OnDemand/roles/appd/files'){
                    sh "sh syncdb.sh Staging hotfix latest"
                }
            }
        }
        stage ('Update appd ECS'){
            when {expression {params.Environment == 'hotfix'}}

            steps{
                dir ('Terraform/OnDemand/'){
                    withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                        sh "ansible-playbook ondemand_appd_deploy_container.yml -i latest_hosts -l 'appd-latest' -e env='hotfix' -e key_pair=${keyfile}"
                    }
                }
            }
        }

        stage ('Build and Deploy containers'){
            when {expression {params.Environment == 'hotfix'}}

            steps{
                dir ('Terraform/OnDemand/'){
                    withCredentials([usernamePassword(credentialsId: 'dustin_gitlab_read_only_pat_token', passwordVariable: 'gitlab_token', usernameVariable: 'user')]) {
                        withCredentials([sshUserPrivateKey(credentialsId: '57a3f7be-c286-4a5c-938d-acc0152f1cad', keyFileVariable: 'keyfile', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                            sh "ansible-playbook ondemand_ecs.yml -i latest_hosts  -e env='hotfix' -e gitlab_pat_token=${gitlab_token}"
                        }
                    }
                }
            }
        }
    }
}

def getTerraformPath() {
    def tfHome = tool name: 'Terraform-12.13', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
    return tfHome
}

