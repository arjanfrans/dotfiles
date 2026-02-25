cd ~/.dotfiles

rm -rf ./kustomize

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

ln -sf ~/.dotfiles/kustomize ~/.local/bin/kustomize
