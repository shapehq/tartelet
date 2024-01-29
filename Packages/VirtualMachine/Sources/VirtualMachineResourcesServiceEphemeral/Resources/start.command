#!/bin/zsh
PRE_RUN_SCRIPT="pre-run.sh"
POST_RUN_SCRIPT="post-run.sh"
ACTIONS_RUNNER_ARCHIVE=./actions-runner.tar.gz
ACTIONS_RUNNER_DIRECTORY=~/actions-runner
WORK_DIRECTORY=_work
RUNNER_NAME_FILE=./RUNNER_NAME
RUNNER_URL_FILE=./RUNNER_URL
RUNNER_TOKEN_FILE=./RUNNER_TOKEN
RUNNER_DOWNLOAD_URL_FILE=./RUNNER_DOWNLOAD_URL
RUNNER_LABELS_FILE=./RUNNER_LABELS
RUNNER_GROUP_FILE=./RUNNER_GROUP

# Ensure the virtual machine is restarted when a job is done.
set -e pipefail
function onexit {
  sudo shutdown -h now
}
trap onexit EXIT

# Run the script from the Resources folder
cd "/Volumes/My Shared Files/Resources"

# Check if files with constants exist
if [ ! -f $RUNNER_NAME_FILE ]; then
  echo "The RUNNER_NAME file was not found"
  exit 1
fi
if [ ! -f $RUNNER_URL_FILE ]; then
  echo "The RUNNER_URL file was not found"
  exit 1
fi
if [ ! -f $RUNNER_TOKEN_FILE ]; then
  echo "The RUNNER_TOKEN file was not found"
  exit 1
fi
if [ ! -f $RUNNER_DOWNLOAD_URL_FILE ]; then
  echo "The RUNNER_DOWNLOAD_URL file was not found"
  exit 1
fi
if [ ! -f $RUNNER_LABELS_FILE ]; then
  echo "The RUNNER_LABELS file was not found"
  exit 1
fi
if [ ! -f $RUNNER_GROUP_FILE ]; then
  echo "The RUNNER_GROUP file was not found"
  exit 1
fi

# Read constants from files
RUNNER_NAME=$(<./RUNNER_NAME)
RUNNER_URL=$(<./RUNNER_URL)
RUNNER_TOKEN=$(<./RUNNER_TOKEN)
RUNNER_DOWNLOAD_URL=$(<./RUNNER_DOWNLOAD_URL)
RUNNER_LABELS=$(<./RUNNER_LABELS)
RUNNER_GROUP=$(<./RUNNER_GROUP)

# Wait until we can connect to GitHub
until curl -Is https://github.com &>/dev/null; do :; done

# Download the runner if the archive does not already exist
if [ ! -f $ACTIONS_RUNNER_ARCHIVE ]; then
  curl -o $ACTIONS_RUNNER_ARCHIVE -L $RUNNER_DOWNLOAD_URL
fi

# Unarchive the runner
mkdir $ACTIONS_RUNNER_DIRECTORY
tar xzf $ACTIONS_RUNNER_ARCHIVE --directory $ACTIONS_RUNNER_DIRECTORY

# Setup the pre- and post-job scripts if needed
if [ -f $PRE_RUN_SCRIPT ]; then
  cp $PRE_RUN_SCRIPT $ACTIONS_RUNNER_DIRECTORY
  export ACTIONS_RUNNER_HOOK_JOB_STARTED="${ACTIONS_RUNNER_DIRECTORY}/${PRE_RUN_SCRIPT}"
fi
if [ -f $POST_RUN_SCRIPT ]; then
  cp $POST_RUN_SCRIPT $ACTIONS_RUNNER_DIRECTORY
  export ACTIONS_RUNNER_HOOK_JOB_COMPLETED="${ACTIONS_RUNNER_DIRECTORY}/${POST_RUN_SCRIPT}"
fi

# Configure and run the runner
cd $ACTIONS_RUNNER_DIRECTORY
./config.sh \
  --url "${RUNNER_URL}" \
  --unattended \
  --ephemeral \
  --replace \
  --labels "${RUNNER_LABELS}" \
  --name "${RUNNER_NAME}" \
  --runnergroup "${RUNNER_GROUP}" \
  --work "${WORK_DIRECTORY}" \
  --token "${RUNNER_TOKEN}"
./run.sh
