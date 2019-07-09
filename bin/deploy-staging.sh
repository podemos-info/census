#!/usr/bin/env bash

set -eo pipefail

if [ "${CIRCLE_BRANCH}" = "master" ]
then
  if [ -z "$STAGING_SERVER_MASTER_HOST" ]
  then
    echo "You need to set the STAGING_SERVER_MASTER_HOST environment variable"
    exit 1
  fi

  if [ -z "$STAGING_SERVER_MASTER_PORT" ]
  then
    echo "You need to set the STAGING_SERVER_MASTER_PORT environment variable"
    exit 1
  fi

  if [ -z "$STAGING_SERVER_SLAVE_HOST" ]
  then
    echo "You need to set the STAGING_SERVER_SLAVE_HOST environment variable"
    exit 1
  fi

  if [ -z "$STAGING_SERVER_SLAVE_PORT" ]
  then
    echo "You need to set the STAGING_SERVER_SLAVE_PORT environment variable"
    exit 1
  fi

  BRANCH=$CIRCLE_BRANCH bundle exec cap staging deploy | \
    sed "s/$STAGING_SERVER_MASTER_HOST/[master_host]/g" | \
    sed "s/$STAGING_SERVER_MASTER_PORT/[master_port]/g" | \
    sed "s/$STAGING_SERVER_SLAVE_HOST/[slave_host]/g" | \
    sed "s/$STAGING_SERVER_SLAVE_PORT/[slave_port]/g"
fi
