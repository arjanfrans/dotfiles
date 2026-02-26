cd ~/.dotfiles

rm -rf ./kustomize

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

ln -sf ~/.dotfiles/kustomize ~/.local/bin/kustomize

chmod +x ~/.dotfiles/kustomize

rm -rf ./kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

ln -sf ~/.dotfiles/kubectl ~/.local/bin/kubectl

chmod +x ~/.dotfiles/kubectl
