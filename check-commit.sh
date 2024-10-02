#!/usr/bin/env bash
set -e

LAST_PROD_COMMIT_ID=`curl --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "https://gitlab-ce.lgcomus-shared.lge.com/api/v4/projects/${CI_PROJECT_ID}/repository/commits/$TARGET_BRANCH" | grep -o '"short_id": *"[^"]*"' | grep -o '"[^"]*"$'`

echo $LAST_PROD_COMMIT_ID

for i in {1..30}
      do
       if  curl --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" "https://gitlab-ce.lgcomus-shared.lge.com/api/v4/projects/${CI_PROJECT_ID}/repository/commits?ref_name=$CI_COMMIT_REF_NAME&sort=desc&per_page=100&page=$i" | grep -o '"short_id": *"[^"]*"' | grep -o $LAST_PROD_COMMIT_ID; then
               echo "found"
               break
       fi
      done
#echo $LAST_PROD_COMMIT_COUNT
#if [ $LAST_PROD_COMMIT_COUNT = "0" ]; then exit 1; fi
#echo "commit id found"