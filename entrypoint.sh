#!/bin/bash

# entry.sh was taken from this docker page:
# https://docs.docker.com/config/containers/multi-service_container/
# It's not perfect... or elegant... but it gets the job done.

# We sometimes want to serve from a custom location.
if [ "${WWW_DIR}" != "" ]; then
  sed -i -e 's:/var/www/html:'"${WWW_DIR}"':g' /etc/nginx/sites-enabled/nginx-php-site
fi

# Solution to permission problems by making www-data become whatever UID and GID we want.
if [ "${WWW_DATA_ID}" != "" ]; then
  USER_ID=$(echo ${WWW_DATA_ID} | cut -d: -f1)
  GROUP_ID=$(echo ${WWW_DATA_ID} | cut -d: -f2)

  if [ "${USER_ID}" == "" ] || [ "${GROUP_ID}" == "" ]; then
    echo WWW_DATA_ID must be in UID:GID format.
    exit 1
  fi

  userdel www-data
  groupadd www-data -g "${GROUP_ID}" -o
  useradd -s /bin/false www-data -u "${USER_ID}" -g "${GROUP_ID}" -o
fi

# Start nginx
/usr/sbin/nginx
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi



# Start php-fpm 
/usr/sbin/php-fpm7.4 --allow-to-run-as-root
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start php-fpm: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  ps aux |grep nginx |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep php-fpm |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
