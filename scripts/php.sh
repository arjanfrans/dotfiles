sudo apt-get install php7.0 php7.0-fpm php7.0-mysql -y
sudo apt-get install php7.0-xml
sudo apt-get install php7.0-intl
sudo apt-get install php7.0-mbstring

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
