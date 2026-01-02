#!/bin/bash
clear

echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e " 🚀 Starting Automated Jexactyl Installer By ShadowPrince"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo ""

read -p "🌐 Enter your domain (example: panel.example.com): " DOMAIN
read -s -p "🔑 Enter MariaDB root password: " MYSQL_ROOT_PASS
echo ""

# --- Dependencies & Repos ---
echo -e "\n📦 Installing required dependencies..."
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg lsb-release

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

# Redis repo
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

# MariaDB repo (skip if Ubuntu 22.04+)
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash

apt update
apt -y install php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# --- Download & Prepare Panel ---
mkdir -p /var/www/jexactyl
cd /var/www/jexactyl

curl -Lo panel.tar.gz https://github.com/jexactyl/jexactyl/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# --- MariaDB Setup ---
echo -e "\n🗄 Setting up database..."
mysql -u root -p"${MYSQL_ROOT_PASS}" <<MYSQL_SCRIPT
CREATE USER 'jexactyl'@'127.0.0.1' IDENTIFIED BY 'para';
CREATE DATABASE panel;
GRANT ALL PRIVILEGES ON panel.* TO 'jexactyl'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# --- Environment & Laravel Setup ---
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force

php artisan p:environment:setup
php artisan p:environment:database

php artisan migrate --seed --force
php artisan p:user:make

# --- Permissions ---
chown -R www-data:www-data /var/www/jexactyl/*

# --- SSL via Certbot ---
apt install -y certbot python3-certbot-nginx
certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m admin@${DOMAIN}

# --- Nginx Configuration ---
rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/panel.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/jexactyl/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/jexactyl.app-error.log error;

    client_max_body_size 100M;
    client_body_timeout 120s;

    sendfile off;

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/panel.conf /etc/nginx/sites-enabled/panel.conf || true

nginx -t && systemctl restart nginx

# --- Final Output ---
clear
echo -e "\n\e[1;32m✅ Jexactyl Panel Installation Finished!\e[0m\n"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e " 🌐 Panel URL:        \e[1;37mhttps://${DOMAIN}\e[0m"
echo -e " 📂 Installation Dir: \e[1;37m/var/www/jexactyl\e[0m"
echo -e " 👤 Create Admin:     \e[1;37mphp artisan p:user:make\e[0m"
echo -e " 🔑 DB User:          \e[1;37mjexactyl\e[0m"
echo -e " 🔑 DB Password:      \e[1;37mpara\e[0m"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e " 🎉 Enjoy managing your Jexactyl Panel! 🚀"
