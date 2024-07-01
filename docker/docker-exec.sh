#!/bin/bash

# Function to find and exec into a Docker container by name
exec_into_container() {
    local name=$1
    # Get the list of all containers (running and stopped)
    local containers=$(docker ps -a)
    # Loop through each line of the containers list
    while IFS= read -r line; do
        # Check if the current line contains the name substring
        if [[ "$line" =~ $name ]]; then
            # Extract the container ID from the line
            local container_id=$(echo $line | awk '{print $1}')
            # Exec into the container with an interactive TTY
            docker exec -it $container_id /bin/bash
            return
        fi
    done <<< "$containers"
    echo "No container found with name substring: $name"
}

# Parse command-line options
while getopts ":n:--name:" opt; do
    case ${opt} in
        n )
            name=$OPTARG
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Check if name variable is set
if [ -z "${name}" ]; then
    echo "Usage: $0 -n <name>"
    exit 1
fi

# Exec into the container
exec_into_container "${name}"