#!/bin/bash

#=================================================
# IMPORT GENERIC HELPERS
#=================================================

source _common.sh
source /usr/share/yunohost/helpers

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST
#=================================================

app=$YNH_APP_ID
domain=$YNH_APP_ARG_DOMAIN
path=$YNH_APP_ARG_PATH
admin=$YNH_APP_ARG_ADMIN
password=$YNH_APP_ARG_PASSWORD
enable_https=$YNH_APP_ARG_ENABLE_HTTPS
station_ports=$YNH_APP_ARG_STATION_PORTS

#=================================================
# STORE SETTINGS FROM MANIFEST
#=================================================

ynh_app_setting_set --app=$app --key=domain --value=$domain
ynh_app_setting_set --app=$app --key=path --value=$path
ynh_app_setting_set --app=$app --key=admin --value=$admin
ynh_app_setting_set --app=$app --key=enable_https --value=$enable_https
ynh_app_setting_set --app=$app --key=station_ports --value=$station_ports

#=================================================
# CHECK IF THE APP CAN BE INSTALLED WITH THESE ARGS
#=================================================

ynh_script_progression --message="Validating installation parameters..." --weight=1

# Check available disk space (AzuraCast needs at least 2GB)
available_space=$(df $install_dir --output=avail | tail -1)
required_space=$((2 * 1024 * 1024)) # 2GB in KB

if [ $available_space -lt $required_space ]; then
    ynh_die --message="Not enough disk space available. AzuraCast requires at least 2GB of free space."
fi

#=================================================
# INSTALL DEPENDENCIES
#=================================================

ynh_script_progression --message="Installing dependencies..." --weight=10

# Install Docker using helper functions
install_docker

# Install Docker Compose using helper functions
install_docker_compose

#=================================================
# CREATE DEDICATED USER
#=================================================

ynh_script_progression --message="Configuring system user..." --weight=1

# Create a system user for AzuraCast
ynh_system_user_create --username=$app --home_dir="$install_dir"

#=================================================
# DOWNLOAD, CHECK AND UNPACK SOURCE
#=================================================

ynh_script_progression --message="Setting up source files..." --weight=5

# Create the installation directory and set permissions
ynh_app_setting_set --app=$app --key=install_dir --value=$install_dir

# Set permissions
chown -R $app:$app "$install_dir"

#=================================================
# SETUP AZURACAST DOCKER CONFIGURATION
#=================================================

ynh_script_progression --message="Configuring AzuraCast..." --weight=5

# Create AzuraCast directory structure
mkdir -p "$install_dir"
cd "$install_dir"

# Download AzuraCast docker setup script
ynh_exec_as $app curl -fsSL https://raw.githubusercontent.com/AzuraCast/AzuraCast/main/docker.sh > docker.sh
chmod +x docker.sh

# Generate environment configuration
cat > .env <<EOF
# YunoHost AzuraCast Configuration
AZURACAST_VERSION=latest
AZURACAST_HTTP_PORT=$port
AZURACAST_HTTPS_PORT=443
AZURACAST_SFTP_PORT=2022
NGINX_TIMEOUT=1800
LETSENCRYPT_HOST=$domain
LETSENCRYPT_EMAIL=$(ynh_user_get_info --username=$admin --key=mail)
EOF

# Generate AzuraCast environment file
cat > azuracast.env <<EOF
# Application Environment
APPLICATION_ENV=production
LOG_LEVEL=info

# Database Configuration
MYSQL_HOST=mariadb
MYSQL_PORT=3306
MYSQL_USER=azuracast
MYSQL_PASSWORD=$(ynh_string_random --length=32)
MYSQL_DATABASE=azuracast
MYSQL_ROOT_PASSWORD=$(ynh_string_random --length=32)

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Additional Configuration
ENABLE_REDIS=true
COMPOSER_PLUGIN_MODE=false
ADDITIONAL_MEDIA_SYNC_WORKER_COUNT=0
EOF

#=================================================
# CREATE DOCKER COMPOSE FILE
#=================================================

ynh_script_progression --message="Creating Docker Compose configuration..." --weight=2

# Generate docker-compose.yml with YunoHost-specific modifications
ynh_add_config --template="docker-compose.yml" --destination="$install_dir/docker-compose.yml"

#=================================================
# CONFIGURE NGINX
#=================================================

ynh_script_progression --message="Configuring NGINX web server..." --weight=2

# Create NGINX configuration
ynh_add_nginx_config

#=================================================
# SETUP SYSTEMD
#=================================================

ynh_script_progression --message="Configuring a systemd service..." --weight=1

# Create systemd service for AzuraCast
ynh_add_systemd_config

#=================================================
# SETUP APPLICATION WITH DOCKER
#=================================================

ynh_script_progression --message="Installing AzuraCast with Docker (this may take several minutes)..." --weight=30

# Set proper permissions
chown -R $app:$app "$install_dir"

# Run AzuraCast installation
cd "$install_dir"
ynh_exec_as $app ./docker.sh install

# Create initial admin user
compose_cmd=$(get_docker_compose_cmd)
ynh_exec_as $app $compose_cmd exec -T web azuracast_cli azuracast:account:create --email="$(ynh_user_get_info --username=$admin --key=mail)" --password="$password" --admin

#=================================================
# SETUP LOGROTATE
#=================================================

ynh_script_progression --message="Configuring log rotation..." --weight=1

# Use logrotate to manage application logfile(s)
ynh_use_logrotate --specific_user=$app

#=================================================
# INTEGRATE SERVICE IN YUNOHOST
#=================================================

ynh_script_progression --message="Integrating service in YunoHost..." --weight=1

yunohost service add $app --description="AzuraCast web radio management" --log="/var/log/$app/$app.log"

#=================================================
# START SYSTEMD SERVICE
#=================================================

ynh_script_progression --message="Starting a systemd service..." --weight=1

# Start a systemd service
ynh_systemd_action --service_name=$app --action="start" --log_path="/var/log/$app/$app.log"

#=================================================
# SETUP FAIL2BAN
#=================================================

ynh_script_progression --message="Configuring Fail2Ban..." --weight=1

# Create a dedicated Fail2Ban config
ynh_add_fail2ban_config --logpath="/var/log/nginx/${domain}-error.log" --failregex="Regex for AzuraCast failed login attempts"

#=================================================
# SETUP SSOWAT
#=================================================

ynh_script_progression --message="Configuring permissions..." --weight=1

# Make app public if necessary
if [ $is_public -eq 1 ]
then
    ynh_permission_update --permission="main" --add="visitors"
fi

#=================================================
# RELOAD NGINX
#=================================================

ynh_script_progression --message="Reloading NGINX web server..." --weight=1

ynh_systemd_action --service_name=nginx --action=reload

#=================================================
# SEND A README FOR THE ADMIN
#=================================================

ynh_script_progression --message="Sending readme to admin..." --weight=1

admin_mail=$(ynh_user_get_info --username=$admin --key=mail)

cat > /tmp/azuracast_readme <<EOF
AzuraCast has been successfully installed!

Domain: https://$domain$path

Administrator account:
- Email: $admin_mail
- Password: [The password you provided during installation]

Your AzuraCast installation supports up to $station_ports radio stations.
Radio streams will be available on ports 8000-80$(printf "%02d" $((station_ports - 1))).

Important notes:
- This is a Docker-based installation, so standard YunoHost backup/restore may not work perfectly
- To manage your installation, you can use:
  - The web interface at https://$domain$path
  - SSH access: cd $install_dir && sudo -u $app ./docker.sh [command]
- For updates, run: cd $install_dir && sudo -u $app ./docker.sh update-self && sudo -u $app ./docker.sh update

Please refer to the AzuraCast documentation for more information:
https://www.azuracast.com/docs/

Enjoy your new web radio station!
EOF

ynh_send_readme_to_admin --app_message="/tmp/azuracast_readme" --recipients="$admin"

#=================================================
# END OF SCRIPT
#=================================================

ynh_script_progression --message="Installation of AzuraCast completed" --last