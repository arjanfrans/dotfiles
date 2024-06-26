# Change the shell theme along with vim colorscheme
theme() {
	if [ "$1" = "list" ]; then
		ls $HOME/.dotfiles/colorschemes/base16-builder/output/shell;
		return
	fi

	script="$HOME/.dotfiles/colorschemes/base16-builder/output/shell/base16-$1.sh"
	script_name=$(basename $script .sh)
	theme=${script_name#*-}
	variation=${theme#*.}
	theme=${theme%.*}

	source $script
	ln -fs $script ~/.base16_theme
	export BASE16_THEME=base16-{$theme}
	export BASE16_VARIATION=$variation
	if type tmux_${variation} >/dev/null; then
		tmux_${variation}
	fi
	[ -f ~/.vimrc_background ] && rm ~/.vimrc_background
	echo -e "set background=$variation\ncolorscheme base16-$theme\n" > ~/.vimrc_background
}

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
