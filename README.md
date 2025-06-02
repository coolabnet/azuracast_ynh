# AzuraCast for YunoHost

[![Integration level](https://dash.yunohost.org/integration/azuracast.svg)](https://dash.yunohost.org/appci/app/azuracast) ![Working status](https://ci-apps.yunohost.org/ci/badges/azuracast.status.svg) ![Maintenance status](https://ci-apps.yunohost.org/ci/badges/azuracast.maintain.svg)

[![Install AzuraCast with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=azuracast)

*[Read this README in other languages.](./ALL_README.md)*

> *This package allows you to install AzuraCast quickly and simply on a YunoHost server.*
> *If you don't have YunoHost, please consult [the guide](https://yunohost.org/install) to learn how to install it.*

## Overview

AzuraCast is a self-hosted, all-in-one web radio management suite. Using its easy installer tools and web interface, you can start up a fully working web radio station in a few quick minutes.

AzuraCast works for web radio stations of all types and sizes, and is built to run on even the most affordable VPS web hosts. The project is named after Azura Peavielle, the mascot of its predecessor project.

**Key Features:**
- **Web-based Management**: Complete radio station management through a modern web interface
- **Multiple Station Support**: Run multiple radio stations from a single installation
- **Auto DJ**: Automated playlist management and song rotation
- **Live Streaming**: Support for live DJs with automatic fallback to Auto DJ
- **Listener Statistics**: Detailed analytics and reporting for your audience
- **API Access**: RESTful API for custom integrations
- **Mobile Responsive**: Fully responsive design works on all devices
- **Podcast Support**: Publish podcasts alongside your radio streams

**Shipped version:** 0.20.2~ynh1

**Demo:** [https://demo.azuracast.com/](https://demo.azuracast.com/)

## Important Notes

⚠️ **Docker-based Installation**: This YunoHost package uses Docker to run AzuraCast, which means:
- It has **limited integration** with YunoHost's SSO and LDAP systems
- Standard YunoHost backup/restore may have limitations
- The app runs in isolated Docker containers

🔧 **System Requirements:**
- Minimum 2GB RAM recommended
- At least 2GB free disk space
- Docker will be automatically installed if not present

📻 **Radio Streaming Ports:**
- Web interface: accessed through your domain/path
- Radio streams: ports 8000-8050 (configurable during installation)
- SFTP uploads: port 2022

## Screenshots

![AzuraCast Dashboard](./doc/screenshots/dashboard.png)
![Station Management](./doc/screenshots/station.png)

## Configuration

### Initial Setup

After installation:

1. Access your AzuraCast installation at your configured domain
2. Complete the initial setup wizard
3. Create your first radio station
4. Upload media files via the web interface or SFTP

### Managing Your Installation

You can manage your AzuraCast installation using:

- **Web Interface**: Full management through the browser
- **Command Line**: SSH to your server and use:
  ```bash
  cd /var/www/azuracast
  sudo -u azuracast ./docker.sh [command]
  ```

### Available Commands

- `./docker.sh start` - Start AzuraCast
- `./docker.sh stop` - Stop AzuraCast
- `./docker.sh restart` - Restart AzuraCast
- `./docker.sh update` - Update to the latest version
- `./docker.sh backup` - Create a backup
- `./docker.sh restore [backup-file]` - Restore from backup

### SFTP Access

Upload media files via SFTP:
- **Host**: your-domain.com
- **Port**: 2022
- **Username**: Your station's SFTP username (configured in AzuraCast)
- **Password**: Your station's SFTP password

## Documentation and Resources

- **Official User Documentation**: [https://www.azuracast.com/docs/](https://www.azuracast.com/docs/)
- **Official Admin Documentation**: [https://www.azuracast.com/docs/administration/](https://www.azuracast.com/docs/administration/)
- **Upstream App Code Repository**: [https://github.com/AzuraCast/AzuraCast](https://github.com/AzuraCast/AzuraCast)
- **YunoHost Store**: [https://apps.yunohost.org/app/azuracast](https://apps.yunohost.org/app/azuracast)
- **Report a Bug**: [https://github.com/YunoHost-Apps/azuracast_ynh/issues](https://github.com/YunoHost-Apps/azuracast_ynh/issues)

## Limitations

- **No SSO Integration**: Users must create separate accounts in AzuraCast
- **Limited YunoHost Backup**: Due to Docker architecture, standard YunoHost backup may not capture all data
- **Single Instance**: Only one AzuraCast installation per YunoHost server (multi_instance = false)
- **Resource Intensive**: Requires significant CPU and RAM for audio processing

## Troubleshooting

### Common Issues

**Installation fails with Docker errors:**
- Ensure your server has enough disk space (minimum 2GB free)
- Check that Docker daemon is running: `systemctl status docker`

**Radio streams not accessible:**
- Verify firewall allows traffic on ports 8000-8050
- Check that streams are configured and started in AzuraCast

**Web interface not loading:**
- Check nginx configuration: `nginx -t`
- Verify AzuraCast containers are running: `cd /var/www/azuracast && sudo -u azuracast docker-compose ps`

### Log Files

- **YunoHost logs**: `/var/log/azuracast/azuracast.log`
- **AzuraCast logs**: `cd /var/www/azuracast && sudo -u azuracast docker-compose logs`
- **Nginx logs**: `/var/log/nginx/[domain]-error.log`

## Developer Info

**Package Repository**: [https://github.com/YunoHost-Apps/azuracast_ynh](https://github.com/YunoHost-Apps/azuracast_ynh)

Please send your pull requests to the `testing` branch.

To try the `testing` branch, please proceed like that:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/azuracast_ynh/tree/testing --debug
```

or

```bash
sudo yunohost app upgrade azuracast -u https://github.com/YunoHost-Apps/azuracast_ynh/tree/testing --debug
```

**More info regarding app packaging**: [https://yunohost.org/packaging_apps](https://yunohost.org/packaging_apps)

## License

AzuraCast is licensed under the Apache License 2.0. See the [LICENSE](https://github.com/AzuraCast/AzuraCast/blob/main/LICENSE.txt) file for details.

## Support

- **YunoHost Support**: [https://yunohost.org/help](https://yunohost.org/help)
- **AzuraCast Support**: [https://www.azuracast.com/docs/help/](https://www.azuracast.com/docs/help/)
- **Community Forum**: [https://community.azuracast.com/](https://community.azuracast.com/)

---

*This README was automatically generated by [yunohost-app-generator](https://github.com/YunoHost/apps_tools/tree/main/apps_tools/app_generator)*