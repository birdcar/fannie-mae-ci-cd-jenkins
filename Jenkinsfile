pipeline {
    agent any

    environment {
      IMAGE_NAME = "birdcar/ci-cd-demo"
      CONDA_ENVIRONMENT_NAME = "ci-cd-demo"
    }

    stages {
      stage("Build") {
        steps {
            script {
              def secretFilePath = "${WORKSPACE}/.psm_token_secret_temp"

              try {
                withCredentials([string(credentialsId: 'psm_token', variable: 'PSM_TOKEN')]) {
                  writeFile(file: secretFilePath, text: PSM_TOKEN)

                  // Restrict permissions on the secret file
                  sh "chmod 400 ${secretFilePath}"
                }

                def condaContainer = docker.build(
                  "${DOCKER_IMAGE_NAME}",
                  "-f Dockerfile --secret id=conda_token,src=${secretFilePath} ."
                )
                echo "Docker image '${DOCKER_IMAGE_NAME}' built successfully"

                condaContainer.push('latest');
              } finally {
                if (fileExists(secretFilePath)) {
                  sh "rm -f ${secretFilePath}"
                  echo "Cleaned up temporary secret file: ${secretFilePath}"
                }
              }
            }
        }
      }
    }
}
