#!/bin/bash

manifest_file=$(find "$(pwd)" -name AndroidManifest.xml)
package_name=$(grep -oP 'package="\K[^"]+' "$manifest_file")
activity_list=$(grep -oP '<activity[^>]+/>' "$manifest_file" | grep -oP 'android:name="\K[^"]+')
successful_activities=()
for activity in $activity_list; do
    output=$(adb shell "cmd package resolve-activity --brief $package_name/$activity" 2>&1)
    if [[ $output == *"Error type 3"* ]]; then
        continue
    elif [[ $output == *"No activity found"* ]]; then
        continue
    fi

    command="adb shell 'am start -n $package_name/$activity'"
    echo "$command"
    output=$(eval "$command" 2>&1)
    if [[ $output == *"Activity not started"* ]]; then
        echo "Activity $activity not started."
    else
        echo "$output"
        successful_activities+=("$activity")
    fi

    sleep 0.4
done
echo " "
echo "Successfully started activities:"
for activity in "${successful_activities[@]}"; do
    echo "- $activity"
done
