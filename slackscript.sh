#!/bin/bash
set -euo pipefail
FAILURE=1
SUCCESS=0
#ENVIRONMENTNAME=prd
function print_slack_summary_build() {
local slack_msg_header
    local slack_msg_body
    local slack_channel
# Populate header and define slack channels
slack_msg_header=":x: *[$CI_PROJECT_NAME] Deployment stage $CI_JOB_NAME failed*"
if [[ "${EXIT_STATUS}" == "${SUCCESS}" ]]; then
        slack_msg_header=":heavy_check_mark: *[$CI_PROJECT_NAME] Deployment stage $CI_JOB_NAME succeeded*"
        #slack_channel="$CHANNEL_TEST"
    fi
cat <<-SLACK
            {
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "${slack_msg_header}"
                        }
                    },
                    {
                        "type": "divider"
                    },
                    {
                        "type": "section",
                        "fields": [
                            {
                                "type": "mrkdwn",
                                "text": "*Stage:*\n$CI_JOB_STAGE"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Pushed By:*\n${GITLAB_USER_NAME}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Job URL:*\n$CI_PIPELINE_URL/"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Branch:*\n${CI_COMMIT_REF_NAME}"
                            }
                        ]
                    },
                    {
                        "type": "divider"
                    }
                ]
}
SLACK
}
function share_slack_update_deploy() {
#local slack_webhook
#slack_webhook="$SLACKWEBHOOKURL"
curl -k -X POST -H "Content-type: application/x-www-form-urlencoded"                                          \
        --data-urlencode "payload=$(print_slack_summary_build)"  \
        "${SLACK_URL}"
}
