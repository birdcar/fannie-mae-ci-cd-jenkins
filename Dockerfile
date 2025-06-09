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

ENTRYPOINT ["./entrypoint.sh"]
