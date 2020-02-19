#!/bin/sh -e

# Inspired by https://community.atlassian.com/t5/Jira-questions/How-to-add-user-to-project-role-using-jira-rest-api-and-json/qaq-p/593827#M197010

# instance properties
jira_instance='https://issues.apache.org/jira/rest/api/2'
username='YOUR ASF JIRA USERNAME'
password='YOUR ASF JIRA PASSWORD'

user_to_add=$1

projects='NIFI NIFIREG NIFILIBS MINIFI MINIFICPP'

# https://stackoverflow.com/a/226724
while true; do
    read -p "Adding ${user_to_add} to Contributor role for projects: ${projects}. Continue? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

for proj in $projects; do
  echo "Adding user ${user_to_add} to contributors for ${proj}"

  project_details=$(curl -u "${username}:${password}" -s -H 'Content-Type:application/json' -H 'Accept: application/json' \
    -X GET \
    "${jira_instance}/project/${proj}/role")

  contributor_role=$(echo "${project_details}" | jq  -r ."Contributors")
  echo "Role for Contributors in ${proj}: ${contributor_role}"

  role_id=$(curl -s -H 'Content-Type:application/json' -H 'Accept: application/json' \
    -X GET \
    "${contributor_role}" | jq .id)

  curl -u "${username}:${password}" -H "Content-Type:application/json" -X POST -d '{"user":["'"${user_to_add}"'"]}' "${jira_instance}/project/${proj}/role/${role_id}"
  echo "Added ${user_to_add} to Contributor role for ${proj}"
done
