# Mount a 100 MB tmpfs (RAM) over a directory. Usage: ramdir <dir>
ramdir() {
    local real="$(readlink -m "$1")"
    echo "$real"
    sudo mount -t tmpfs -o size=100m tmpfs "$real"
}

# Mount a tmpfs (RAM) disk at /mnt/ramdisk. Usage: ramdisk <size, e.g. 1g>
ramdisk() {
    sudo mkdir -p /mnt/ramdisk
    sudo mount -t tmpfs -o size="$1" tmpfs /mnt/ramdisk
}

# Fetch with prune and delete local branches whose remote branch is gone
gitclean() {
    git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done
}

# SSH into an EC2 instance (eu-central-1) via EC2 Instance Connect. Usage: ec2 <instance-id>
ec2() {
    export AWS_DEFAULT_REGION=eu-central-1
    mssh ubuntu@$1 -o "IdentitiesOnly=yes"
}

# Run a docker image with the current dir mounted at /app and the host network. Usage: enter_image <entrypoint> <image>
enter_image() {
    if [ $# -lt 2 ]; then
        echo "Usage: enter_image <entrypoint> <image>"
        return 1
    fi
    docker run --rm -it --network host -v "${PWD}:/app" -w "/app" --entrypoint "$1" "$2"
}

# Print the ID of the first running container whose name matches
docker_find() {
    local id="$(docker ps --filter="name=$1" -q | head -n1)"
    if [ -z "$id" ]; then
        echo "No running container matches: $1" >&2
        return 1
    fi
    echo "$id"
}

# Open a bash shell in a running container. Usage: docker_exec <name>
docker_exec() {
    local id
    id="$(docker_find "$1")" && docker exec -it "$id" /bin/bash
}

# Follow the logs of a running container. Usage: docker_logs <name>
docker_logs() {
    local id
    id="$(docker_find "$1")" && docker logs -f "$id"
}

# Force-remove all containers, running or stopped
docker_rm_all() {
    docker rm -f $(docker ps -aq)
}

# Revert file mode (chmod) changes in the working tree, keep content changes
git-reset-fmode() {
    git diff -p -R --no-ext-diff --no-color | grep -E "^(diff|(old|new) mode)" --color=never | git apply
}

# Strip a prefix from the names of files that start with it. Usage: str_remove_prefix <prefix>
str_remove_prefix() {
    for file in "$1"*; do mv "$file" "${file#$1}"; done;
}

# Envsubst a kustomize dir and build it (overlay $KUSTOMIZE_ENVIRONMENT if present). Usage: k_kustomize <dir> <output-file>
k_kustomize() {
    rm -rf __kustomize

    # prepare directory structure
    for d in `find "$1" -type d`
    do
        mkdir -p "__kustomize/$d"
    done

    # copy substituted files
    for f in `find "$1" -type f`
    do
        envsubst < $f > "__kustomize/$f"
    done

    if [ -d "__kustomize/$1/overlays/${KUSTOMIZE_ENVIRONMENT}/" ]
    then
        kubectl kustomize "__kustomize/$1/overlays/${KUSTOMIZE_ENVIRONMENT}/" > "${2}"
    else
        kubectl kustomize "__kustomize/$1/" > "${2}"
    fi
}

# List custom functions and aliases with the comment above each one
mycmds() {
    local file
    for file in $HOME/.dotfiles/{zsh,docker,private/zsh}/*.zsh(N); do
        print -P "%B${file#$HOME/.dotfiles/}%b"
        awk '
            /^#/ { doc = (doc ? doc " " : "") substr($0, 3); next }
            /^[A-Za-z_][A-Za-z0-9_-]*\(\)/ { name = $0; sub(/\(\).*/, "", name) }
            /^alias / { name = $0; sub(/^alias /, "", name); sub(/=.*/, "", name) }
            name { printf "  %-20s %s\n", name, (doc ? doc : "\033[31m(undocumented)\033[0m") }
            { doc = ""; name = "" }
        ' "$file"
        echo
    done

    print -P "%Bgit/gitconfig%b"
    awk '
        /^\[/ { in_alias = ($0 ~ /^\[alias\]/); doc = ""; next }
        !in_alias { next }
        /^[ \t]*#/ { line = $0; sub(/^[ \t]*# ?/, "", line); doc = (doc ? doc " " : "") line; next }
        /=/ { name = $0; sub(/^[ \t]*/, "", name); sub(/[ \t]*=.*/, "", name)
              printf "  git %-16s %s\n", name, (doc ? doc : "\033[31m(undocumented)\033[0m") }
        { doc = "" }
    ' $HOME/.dotfiles/git/gitconfig
}
