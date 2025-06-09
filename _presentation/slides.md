---
# You can also start simply with 'default'
theme: default
title: CI/CD with Anaconda PSM
info: |
  ## CI/CD Best Practices with Anaconda PSM
  This will cover the best things you can do to succeed with Anaconda PSM.

  Learn more at [Sli.dev](https://sli.dev)
# apply unocss classes to the current slide
class: text-center
# https://sli.dev/features/drawing
drawings:
  persist: false
# enable MDC Syntax: https://sli.dev/features/mdc
mdc: true
# open graph
# seoMeta:
#  ogImage: https://cover.sli.dev
---

# CI/CD with Anaconda PSM

Best practices, good ideas, and rabbit holes to pursue on your own.

<div @click="$slidev.nav.next" class="mt-12 py-1" hover:bg="white op-10">
  Press Space for next page <carbon:arrow-right />
</div>

<div class="abs-br m-6 text-xl">
  <button @click="$slidev.nav.openInEditor()" title="Open in Editor" class="slidev-icon-btn">
    <carbon:edit />
  </button>
  <a href="https://github.com/birdcar/fannie-mae-ci-cd-jenkins" target="_blank" class="slidev-icon-btn">
    <carbon:logo-github />
  </a>
</div>

---
layout: section
---

# `whoami`

---
layout: two-cols
layoutClass: gap-16
---

# What we're covering today

This is an intense topic, we could spend days going down various workflows and implementations.

So, for today, let's just focus on the part that is unique to my presence: **"How the hell do we make Anaconda work here"**.

::right::

<Toc text-sm minDepth="1" maxDepth="2" />

---

# Assumptions

1. You already know how to make a conda environment
2. You generally know why breaking projects up into environments is a good idea
3. You're using Jenkins (I was told you're using Jenkins)
4. You're somewhat familiar with Docker
5. I am not a Jenkins guy (I'm sorry)

---
layout: section
---

# Environments as code

---
level: 2
---

# Review: Using an environment.yml file

```bash [/bin/bash]
# Generating an environment.yml file (you'll need to remove 'prefix' key)
$ conda env export --from-history > environment.yml

# Create the environment from a file
$ conda env create -f environment.yml

# Create the environment from a file, but override the "name" field
$ conda env create -f environment.yml -n new_name_i_like_more

# Update an environment
$ conda env update -f environment.yml
```

---
layout: two-cols
layoutClass: gap-16
level: 2
---

# Anatomy of an Envirionment file

1. Keep `environment.yml` with source
2. (optional) Keep the project name simple
3. Ensure your channels are listed and are in priority order
4. Use `nodefaults` to disable default channels (just in case)
5. Define only your direct dependencies (let PSM work for you)
6. Be only as specific as you need to be (let conda work for you)

::right::

```yaml [environment.yml] {*|1|2-9|3-4|3-7|8-9|10-26}{lines: true}
name: ci-cd-demo
channels:
   # Place whatever channels you want the project to pull from here
  - https://repo.anaconda.cloud/repo/anaconda-tam/engineering-main
  # Since this environment will be used by developers as well as in production,
  # include an msys2-based channel for windows users
  - https://repo.anaconda.cloud/repo/anaconda-tam/engineering-win
  # Ensure that 'defaults' channels are not used regardless of environment
  - nodefaults
dependencies:
  - python=3.12
  - typer
  - loguru
  - tqdm
  - ipython
  - jupyterlab
  - matplotlib
  - notebook
  - numpy
  - pandas
  - ruff
  - pytest
  - python-dotenv
  - boto3
  - awscli
```

---
layout: section
---

# Docker

---
layout: two-cols
level: 2
transition: slide-up
---

# Image setup (pt. 1)

1. Use the official Miniconda image as your build base
2. Make the Environment Name a build argument
3. Specify any global configuration as environment variables
4. Install `conda-token` in the `base` environment
5. Inject the token `conda install` needs as a Docker Secret

:: right ::

```dockerfile [Dockerfile] {*|1-2|4-5|7-9|11-12|14-16|*}{lines:true}
# Use the official Miniconda image as base
FROM continuumio/miniconda3:latest

# Gather any build args from the environment
ARG ENV_NAME="ci-cd-demo"

# Set environment variables for non-interactive conda operations
ENV CONDA_ALWAYS_YES="true"
ENV CONDA_CHANNEL_PRIORITY="strict"

# Ensure conda-token is installed
RUN conda install conda-token --name base

# Get the conda token from a Docker secret
RUN --mount=type=secret,id=conda_token \
  conda token set "$(cat /run/secrets/conda_token)"
```

---
layout: two-cols
level: 2
---

# Image Setup (pt. 2)

1. Use the official Miniconda image as your build base
2. Make the Environment Name a build argument
3. Specify any global configuration as environment variables
4. Install `conda-token` in the `base` environment
5. Inject the token `conda install` needs as a Docker Secret

:: right ::

```dockerfile [Dockerfile] {*|18-19|21-22|24-27|29-30|*}{lines:true, startLine: 18}
# Set a working directory
WORKDIR /app

# Copy your environment.yml into the container
COPY environment.yml .

# Create the conda environment from the environment.yml
# and remove packages cache to keep image small
RUN conda env create -f environment.yml -n "${ENV_NAME}"\
    && conda clean --all -y

# Copy your application code
COPY . .
```

---
layout: section
---

# Jenkins

---

```groovy
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
                  "${IMAGE_NAME}",
                  "-f Dockerfile --secret id=conda_token,src=${secretFilePath} ."
                )
                echo "Docker image '${IMAGE_NAME}' built successfully"

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
```

---
layout: section
---

# Q & A
