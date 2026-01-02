#!/bin/bash
clear

echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e " 🚀  Starting Automated Paymenter Installer (Self-Signed SSL)"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo ""

read -p "🌐 Enter your Paymenter domain (example: billing.example.com): " DOMAIN
read -p "🔑 Enter database password you want for Paymenter: " DB_PASS

DB_NAME="paymenter"
DB_USER="paymenter"

# Install dependencies
echo -e "\n📦 Installing system dependencies..."
apt update && apt install -y curl sudo git tar unzip lsb-release ca-certificates apt-transport-https software-properties-common

OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "ubuntu" ]]; then
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
elif [[ "$OS" == "debian" ]]; then
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/sury-php.list
fi

# Redis repo
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

apt update

echo -e "🛠 Installing PHP 8.3, Nginx, MariaDB & Redis..."
apt install -y nginx mariadb-server redis-server php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,intl}

# Download Paymenter
echo -e "📥 Downloading Paymenter..."
mkdir -p /var/www/paymenter
cd /var/www/paymenter
curl -Lo paymenter.tar.gz https://github.com/paymenter/paymenter/releases/latest/download/paymenter.tar.gz
tar -xzvf paymenter.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# DB setup
echo -e "🗄 Setting up MariaDB..."
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
mariadb -e "CREATE DATABASE ${DB_NAME};"
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;"
mariadb -e "FLUSH PRIVILEGES;"

echo -e "⚙ Generating .env..."
cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env

# Composer install
echo -e "🎼 Installing Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo -e "🔑 Laravel initialization..."
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan storage:link
php artisan migrate --force --seed
php artisan db:seed --class=CustomPropertySeeder
php artisan app:init
php artisan app:user:create

echo -e "🔒 Setting permissions..."
chown -R www-data:www-data /var/www/paymenter

echo -e "🕒 Creating cronjob..."
(crontab -u www-data -l 2>/dev/null; echo "* * * * * php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -

echo -e "⚡ Creating queue worker service..."
tee /etc/systemd/system/paymenter.service > /dev/null << EOF
[Unit]
Description=Paymenter Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/paymenter/artisan queue:work
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now redis-server
systemctl enable --now paymenter.service

# SSL self-signed
echo -e "🔐 Generating self-signed SSL..."
mkdir -p /etc/certs/paymenter
cd /etc/certs/paymenter
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
  -subj "/C=NA/ST=NA/L=NA/O=SelfSigned/CN=${DOMAIN}" \
  -keyout privkey.pem -out fullchain.pem

# Nginx config
echo -e "🌍 Configuring Nginx..."
tee /etc/nginx/sites-available/paymenter.conf > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};
    root /var/www/paymenter/public;

    ssl_certificate /etc/certs/paymenter/fullchain.pem;
    ssl_certificate_key /etc/certs/paymenter/privkey.pem;

    index index.php;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

ln -s /etc/nginx/sites-available/paymenter.conf /etc/nginx/sites-enabled/ || true
nginx -t && systemctl restart nginx

clear
echo -e "\n\e[1;32m🎉 Paymenter Installed Successfully!\e[0m\n"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e " 🌐 URL:            \e[1;37mhttps://${DOMAIN}\e[0m"
echo -e " 📂 Directory:      \e[1;37m/var/www/paymenter\e[0m"
echo -e " 🔑 DB Username:    \e[1;37m${DB_USER}\e[0m"
echo -e " 🔑 DB Password:    \e[1;37m${DB_PASS}\e[0m"
echo -e " ⚠ Self-signed SSL certificate generated"
echo -e " 📌 Browser will show 'Not Secure' warning until trusted manually"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
