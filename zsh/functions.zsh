

ramdir() {
    real="$(readlink -m $1)"
    echo $real
    sudo mount -t tmpfs -o size=100m tmpfs $real
}

ramdisk() {
    sudo mkdir -p /mnt/ramdisk
    sudo mount -t tmpfs -o size=$1 tmpfs /mnt/ramdisk
}

gitclean() {
    git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done
}

ec2() {
    export AWS_DEFAULT_REGION=eu-central-1 
    mssh ubuntu@$1 -o "IdentitiesOnly=yes"
}

enter_image() {
    docker run --rm -it -v "${PWD}:/app" -w "/app" --entrypoint "$1" $2
}

docker_exec() {
    docker exec -it $(docker ps --filter="name=$1" -q) /bin/bash
}

docker_logs() {
    docker logs $(docker ps --filter="name=$1" -q) -f
}

git-reset-fmode() {
    git diff -p -R --no-ext-diff --no-color | grep -E "^(diff|(old|new) mode)" --color=never | git apply
}

repo_inspect() {
    docker run --rm -v ${PWD}:/repo felix/gitinspector:0.4.4 --format=html --grading > stats.html
}

str_remove_prefix() {
    for file in $1*; do mv "$file" "${file#$1}"; done;
}
