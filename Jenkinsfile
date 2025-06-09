pipeline {
    agent any
    environment {
      IMAGE_NAME = "${IMAGE_NAME}"
      CONDA_ENVIRONMENT_NAME = "${CONDA_ENVIRONMENT_NAME}"
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

                docker.build(
                  "${DOCKER_IMAGE_NAME}",
                  "-f Dockerfile --secret id=conda_token,src=${secretFilePath} ."
                )

                echo "Docker image '${DOCKER_IMAGE_NAME}' built successfully"
              } finally {
                if (fileExists(secretFilePath)) {
                  sh "rm -f ${secretFilePath}"
                  echo "Cleaned up temporary secret file: ${secretFilePath}"
                }
              }
            }
        }
      }

      stage("Lint") {
        agent {
            docker {
                image 'birdcar/ci-cd-demo'
            }
        }
        steps {
            echo "Linting"
        }
      }

      stage("Test") {
        agent {
          docker {
            image "birdcar/ci-cd-demo"
          }
        }
        steps {
          echo "Testing..."
        }
      }

      stage("Deploy") {
        agent {
          image "birdcar/ci-cd-demo"
        }
        steps {
          echo "Deploying...."
        }
      }
    }
}
