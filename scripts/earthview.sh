npm install -g pm2 earthview-wallpapers

pm2 start earthview-wallpapers --name earthview -- --imageDir ~/Pictures/earthview-wallpapers/ --interval 300000
pm2 startup ubuntu
echo "Don't foget: pm2 save"
