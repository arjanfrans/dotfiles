docker_node() {
    docker run --rm -it \
        -p "${1}:${1}" \
        --workdir /usr/app \
        --volume "${PWD}":"/usr/app" \
    node:16 \
        /bin/bash
}

docker_php() {
    PHP_VERSION=8
    IP_ADDRESS=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
    docker build --build-arg PHP_VERSION=${PHP_VERSION} -t arjan-php-cli \
        --file ${HOME}/.dotfiles/docker/php-cli.Dockerfile \
        ${HOME}/.dotfiles/docker

    docker run -it -v ${PWD}:/app \
        -e XDEBUG_CONFIG="client_host=${IP_ADDRESS} log_level=0" \
        -e XDEBUG_SESSION="PHPSTORM" \
        -w /app \
        --entrypoint \
        /bin/bash arjan-php-cli
}

i_own_this() {
    sudo chown -R `whoami`:`whoami` .
}
