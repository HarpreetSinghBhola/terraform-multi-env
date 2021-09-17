node(' '){
    timestamps {
        String aws_credential_id = ""
        String aws_access_id = ""
        String aws_secret_key = ""
        String deploy_wave = ""
        String deploy_mod = ""
        String git_branch = ""

        stage('initialize') {
            def gitRepo = checkout scm
            // String git_url = gitRepo.GIT_URL
            git_branch = gitRepo.GIT_BRANCH.tokenize('/')[-1]
            String git_commit_id = gitRepo.GIT_COMMIT
            String git_short_commit_id = "${git_commit_id[0..6]}"

            if(!AWS_REGION) {
                error("AWS region is empty or not defined.")
            }
            if(!DEPLOY_ENV) {
                error("Deployment environment name is empty or not defined.")
            }
            if(!DEPLOY_MODULE || DEPLOY_MODULE.equals("none/none")) {
                error("Deployment module name is empty or not defined.")
            }
            if(DEPLOY_ENV.equals('dev') || DEPLOY_ENV.equals('qa') || DEPLOY_ENV.equals('ops') || DEPLOY_ENV.equals('sandbox') || DEPLOY_ENV.equals('staging') || DEPLOY_ENV.equals('uat') || DEPLOY_ENV.equals('shared') ) {
                aws_credential_id = "dev-kg-aws"
            } else if (DEPLOY_ENV == "prod") {
                aws_credential_id = "prod-kg-aws"
            }
             if(DEPLOY_ENV == "dev") {
                aws_account = "aws-dev"
            } else if (DEPLOY_ENV == "qa") {
                aws_account = "aws-qa"
            } else if (DEPLOY_ENV == "ops") {
                aws_account = "aws-ops"
            } else if (DEPLOY_ENV == "prod") {
                aws_account = "aws-prod"
            } else if (DEPLOY_ENV == "uat") {
                aws_account = "aws-uat"
            } else if (DEPLOY_ENV == "sandbox") {
                aws_account = "aws-sandbox"
            }else if (DEPLOY_ENV == "staging") {
                aws_account = "aws-staging"
            } else if (DEPLOY_ENV == "shared") {
                aws_account = "aws-shared"
            }
            
            currentBuild.displayName = (currentBuild.number + "-" + DEPLOY_ENV + "-" + git_branch)
            
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: aws_credential_id,
                    usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                aws_access_id = USERNAME
                aws_secret_key = PASSWORD
              }
            if(!aws_access_id) {
                error("AWS access key is empty or not defined.")
            }
            if(!aws_secret_key) {
                error("AWS secret key is empty or not defined.")
            }

            deploy_wave = DEPLOY_MODULE.tokenize('/')[0]
            deploy_mod = DEPLOY_MODULE.tokenize('/')[1]

            if(!deploy_wave) {
                error("Deployment wave name is empty or not defined.")
            }
            if(!deploy_mod) {
                error("Deployment module name is empty or not defined.")
            }
        }

        stage('tf-plan') {
            wrap([$class: 'MaskPasswordsBuildWrapper', varPasswordPairs: [[password: aws_secret_key, var: 'AWS_SECRET']]]) {
                sh """
                export AWS_ACCESS_KEY_ID=${aws_access_id}
                export AWS_SECRET_ACCESS_KEY=${aws_secret_key}
                ./run.sh plan ${aws_account} ${AWS_REGION} ${deploy_wave}/${deploy_mod}
                """
            }
        }
        stage('tf-deployment') {
            if((TERRAFORM_ACTION.equals('apply') || TERRAFORM_ACTION.equals('destroy')) && git_branch.equalsIgnoreCase('master'))
                {
                    input 'WARNING: Applying Terraform updates can result in unrecoverable destruction. Click "Proceed" to confirm Terraform update plan was reviewed and to authorize the updates to be applied, else click "Abort".'
                    wrap([$class: 'MaskPasswordsBuildWrapper', varPasswordPairs: [[password: aws_secret_key, var: 'AWS_SECRET']]]) {
                        sh """
                        export AWS_ACCESS_KEY_ID=${aws_access_id}
                        export AWS_SECRET_ACCESS_KEY=${aws_secret_key}
                        ./run.sh ${TERRAFORM_ACTION} ${aws_account} ${AWS_REGION} ${deploy_wave}/${deploy_mod}
                        """
                     }
                }

            else {
                    println "Skipping Terraform Action, Only 'MASTER' branch can be applied."
                 }       
        }
    }
}