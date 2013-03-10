#!/usr/bin/env bash

git checkout factory
git pull origin factory

# just indicate if things went well, or not
if [ $? -ne 0 ];
then
  echo "Failure: couldn't update."
  exit 1
else
  echo "Update: success."
  exit 0
fi
