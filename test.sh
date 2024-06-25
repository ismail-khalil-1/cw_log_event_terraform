#!/bin/bash

LOG_GROUP_NAME="/aws/rds/instance/vprofile-mysql-rds/error"
LOG_STREAM_NAME="vprofile-mysql-rds"
OUTPUT_FILE="cloudwatch_log_events.txt"

next_token=""
previous_token=""
> "$OUTPUT_FILE" 

while true; do
  if [ -z "$next_token" ]; then
    response=$(aws logs get-log-events --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME" --start-from-head --output json)
  else
    response=$(aws logs get-log-events --log-group-name "$LOG_GROUP_NAME" --log-stream-name "$LOG_STREAM_NAME" --start-from-head --next-token "$next_token" --output json)
  fi

  echo "$response" | jq '.events[] | {timestamp, message}' >> "$OUTPUT_FILE"

  previous_token=$next_token
  next_token=$(echo "$response" | jq -r '.nextForwardToken')

  if [ "$next_token" == "null" ] || [ "$next_token" == "$previous_token" ]; then
    break
  fi
done

if [ $? -ne 0 ]; then
  echo "Failed to fetch log events"
else
  echo "Log events fetched successfully"
  cat "$OUTPUT_FILE"
fi
