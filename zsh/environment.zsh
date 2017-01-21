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

# clang compiler 
# type clang > /dev/null
# if [ $? -eq 0 ]; then
#     export CC=clang
#     export CXX=clang++
# fi

export CC=gcc
export CXX=g++


# Mongodb
mongodir="$HOME/software/mongodb"

if [ -d "$mongodir" ]; then
    export PATH=$HOME/software/mongodb/bin:$PATH
fi

# Android SDK
androiddir="$HOME/Android/Sdk"

if [ -d "$androiddir" ]; then
    export ANDROID_HOME=~/Android/Sdk
    export PATH=${PATH}:${ANDROID_HOME}/tools
    export PATH=${PATH}:${ANDROID_HOME}/platform-tools
fi


