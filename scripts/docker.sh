sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates -y
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "	deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y

sudo apt-get update
sudo apt-get install docker-engine -y

sudo usermod -aG docker ${USER}

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
