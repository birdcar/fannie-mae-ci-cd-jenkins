#!/usr/bin/env bash --login
# The --login above ensures that bash config is loaded, which
# is what enables Conda

# It's typically a good default to enable Strict mode
set -euo pipefall

# However, you have to temporarily disable it to activate an environment
set +euo pipefall
conda activate "${ENV_NAME:-'ci-cd-demo'}"

# Then you can re-enable strict mode for your entrypoint from there
set -euo pipefall

