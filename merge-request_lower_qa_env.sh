#!/usr/bin/env bash
set -e

if [ -z "$GITLAB_PRIVATE_TOKEN" ]; then
  echo "GITLAB_PRIVATE_TOKEN not set"
  echo "Please set the GitLab Private Token as GITLAB_PRIVATE_TOKEN"
  exit 1
fi

# Extract the host where the server is running, and add the URL to the APIs
[[ $CI_PROJECT_URL =~ ^https?://[^/]+ ]] && HOST="${BASH_REMATCH[0]}/api/v4/projects/"

# Branch creation for webdev

        curl --silent --request POST --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "https://gitlab-ce.example-shared.example.com/api/v4/projects/$CI_PROJECT_ID/repository/branches?branch=feature/${CI_PIPELINE_ID}-${CI_JOB_ID}&ref=$TARGET_BRANCH"
        iid=`curl -sk -X POST "${HOST}${CI_PROJECT_ID}/merge_requests" \
        --header "PRIVATE-TOKEN:${GITLAB_PRIVATE_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "{\"id\": ${CI_PROJECT_ID},
                \"source_branch\": \"feature/${CI_PIPELINE_ID}-${CI_JOB_ID}\",
                \"target_branch\": \"release\",
                \"remove_source_branch\": true,
                \"title\": \"Merge branch feature/${CI_PIPELINE_ID}-${CI_JOB_ID} into release\",
                \"assignee_id\":\"${GITLAB_PROJECT_LEAD_ID}\"}" |jq --arg key "iid" '.[$key]'`
        
        echo $iid
        sleep 20;
        
        curl -s -X PUT -H "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
        -H "Content-type: application/json" \
        -d '{"merge_when_pipeline_succeeds": "true", "should_remove_source_branch": "false"}' \
        https://gitlab-ce.lgcomus-shared.lge.com/api/v4/projects/$CI_PROJECT_ID/merge_requests/$iid/merge

