#!/bin/bash

source _common.sh
source /usr/share/yunohost/helpers

# Retrieve arguments
app=$YNH_APP_ID
domain=$YNH_APP_ARG_DOMAIN
path=$YNH_APP_ARG_PATH
admin=$YNH_APP_ARG_ADMIN
password=$YNH_APP_ARG_PASSWORD
station_ports=$YNH_APP_ARG_STATION_PORTS

# Store settings
ynh_app_setting_set --app=$app --key=domain --value=$domain
ynh_app_setting_set --app=$app --key=path --value=$path
ynh_app_setting_set --app=$app --key=admin --value=$admin
ynh_app_setting_set --app=$app --key=station_ports --value=$station_ports

ynh_script_progression --message="Installing dependencies..." --weight=10

# Install Docker
if ! command -v docker &> /dev/null; then
    ynh_exec_warn_less curl -fsSL https://get.docker.com | sh
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    ynh_exec_warn_less curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

ynh_script_progression --message="Setting up AzuraCast..." --weight=20

# Create installation directory
mkdir -p "$install_dir"
chown -R $app:$app "$install_dir"
cd "$install_dir"

# Download AzuraCast
ynh_exec_as $app curl -fsSL https://raw.githubusercontent.com/AzuraCast/AzuraCast/main/docker.sh > docker.sh
chmod +x docker.sh

# Configure environment
cat > .env <<EOF
AZURACAST_VERSION=latest
AZURACAST_HTTP_PORT=$port
AZURACAST_HTTPS_PORT=443
AZURACAST_SFTP_PORT=2022
EOF

# Install AzuraCast
ynh_exec_as $app ./docker.sh install

# Configure nginx
ynh_add_nginx_config

# Setup systemd service
ynh_add_systemd_config

# Create admin user
ynh_exec_as $app docker-compose exec -T web azuracast_cli azuracast:account:create \
  --email="$(ynh_user_get_info --username=$admin --key=mail)" \
  --password="$password" --admin

yunohost service add $app --description="AzuraCast web radio"
ynh_systemd_action --service_name=$app --action="start"

ynh_script_progression --message="Installation completed" --last