if dpkg -l 'apache2*' 2>/dev/null | grep -q '^ii'; then
    sudo apt-get remove -y 'apache2*'
    sudo apt-get autoremove -y
    sudo apt-get autoclean
fi
sudo rm -rf /etc/apache2 /var/lib/apache2
