docker_node() {
    docker run --rm -it \
        -p "${1}:${1}" \
        --workdir /usr/app \
        --volume "${PWD}":"/usr/app" \
    node:10 \
        /bin/bash
}


