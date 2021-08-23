#!/bin/sh -l
set -e

FILE_NAME=$1
KEY=$2
VALUE=$3
GITHUB_DEPLOY_KEY=$4
GITHUB_ORG_AND_REPO=$5

if [ -z $FILE_NAME ]; then
  echo "FILE_NAME no value specified"
  exit 1
fi

if [ -z $KEY ]; then
  echo "KEY no value specified"
  exit 1
fi

if [ -z $VALUE ]; then
  echo "VALUE no value specified"
  exit 1
fi

if [ -z $GITHUB_DEPLOY_KEY ]; then
  echo "GITHUB_DEPLOY_KEY no value specified"
  exit 1
fi

if [ -z $GITHUB_ORG_AND_REPO ]; then
  echo "GITHUB_ORG_AND_REPO no value specified"
  exit 1
fi

mkdir -p ~/.ssh

git config --global user.email "gitops-release@github.com"
git config --global user.name "Gitops Release User"

ssh-keyscan -H github.com >> ~/.ssh/known_hosts

echo "$4" > ~/.ssh/id_gh
chmod 600 ~/.ssh/id_gh

eval `ssh-agent`
ssh-add ~/.ssh/id_gh
git clone https://git@github.com:$GITHUB_ORG_AND_REPO.git  $RUNNER_TEMP/infra-as-code-repo
wget https://raw.githubusercontent.com/simplycubed/gitops-update/master/replace-key.py
python replace-key.py --file $RUNNER_TEMP/infra-as-code-repo/$FILE_NAME --key $KEY --value $VALUE
cd $RUNNER_TEMP/infra-as-code-repo
git add .
git commit -m "Release of key $KEY in $FILE_NAME"
git push
