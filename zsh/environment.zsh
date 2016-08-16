export PATH="$HOME/.rbenv/bin:$PATH"

# Only execute if rbenv is installed.
type rbenv > /dev/null
if [ $? -eq 0 ]; then
    eval "$(rbenv init -)"
fi

nvm_dir="$HOME/.nvm"
if [ -d "$nvm_dir" ]; then
    source "$nvm_dir/nvm.sh"
fi

type clang > /dev/null
if [ $? -eq 0 ]; then
    export CC=clang
    export CXX=clang++
fi

#
# export CC=gcc
# export CXX=g++
#
mongodir="$HOME/software/mongodb"
if [ -d "$mongodir" ]; then
    export PATH=$HOME/software/mongodb/bin:$PATH
fi


