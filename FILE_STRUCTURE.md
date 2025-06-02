# AzuraCast YunoHost Package - File Structure

This document lists all the files created for the azuracast_ynh YunoHost package repository.

## Repository Structure

```
azuracast_ynh/
├── manifest.toml                    # YunoHost app manifest (packaging v2)
├── README.md                        # Main documentation
├── .gitignore                       # Git ignore rules
├── check_process                    # YunoHost CI/CD testing configuration
│
├── scripts/                         # Installation and management scripts
│   ├── _common.sh                   # Common functions and variables
│   ├── install                      # Installation script
│   ├── remove                       # Removal script
│   ├── upgrade                      # Upgrade script
│   ├── backup                       # Backup script
│   ├── restore                      # Restore script
│   └── change_url                   # URL change script
│
└── conf/                           # Configuration templates
    ├── nginx.conf                   # NGINX reverse proxy configuration
    ├── systemd.service              # Systemd service configuration
    ├── docker-compose.yml           # Docker Compose template for AzuraCast
    ├── fail2ban.conf               # Fail2Ban filter configuration
    └── logrotate                   # Log rotation configuration
```

## File Descriptions

### Core Files

- **manifest.toml**: YunoHost packaging v2 manifest defining app metadata, installation questions, and resource requirements
- **README.md**: Comprehensive documentation for users and developers
- **.gitignore**: Excludes temporary files, logs, and sensitive data from version control
- **check_process**: Configuration for YunoHost's automated testing system

### Scripts Directory

- **_common.sh**: Shared functions for Docker management, environment setup, and health checks
- **install**: Main installation script that sets up Docker, downloads AzuraCast, and configures integration
- **remove**: Cleanup script that stops containers, removes data, and uninstalls the application
- **upgrade**: Updates AzuraCast to newer versions while preserving data and configuration
- **backup**: Creates backups of application data, configuration, and Docker volumes
- **restore**: Restores application from backup files and recreates the environment
- **change_url**: Handles domain/path changes for the application

### Configuration Templates

- **nginx.conf**: Reverse proxy configuration that routes traffic to AzuraCast container
- **systemd.service**: Service definition for managing AzuraCast through systemd
- **docker-compose.yml**: Docker Compose template adapted for YunoHost integration
- **fail2ban.conf**: Security filter to block malicious login attempts
- **logrotate**: Automatic log file rotation and compression configuration

## Key Features

### YunoHost Integration
- ✅ **Packaging v2**: Uses latest YunoHost packaging format
- ✅ **Resources**: Proper integration with YunoHost resource system
- ✅ **NGINX**: Reverse proxy configuration with security headers
- ✅ **Systemd**: Service management through YunoHost
- ✅ **Backup/Restore**: Docker-aware backup and restore procedures
- ✅ **Fail2Ban**: Security protection against brute force attacks

### Docker Compatibility
- ✅ **Docker Installation**: Automatic Docker and Docker Compose setup
- ✅ **Container Management**: Proper container lifecycle management
- ✅ **Volume Mapping**: YunoHost data directory integration
- ✅ **Port Configuration**: Configurable radio streaming ports
- ✅ **Health Checks**: Container health monitoring

### AzuraCast Features
- ✅ **Web Interface**: Full web-based radio station management
- ✅ **Multi-Station**: Support for multiple radio stations
- ✅ **Streaming**: Radio stream broadcasting on configurable ports
- ✅ **SFTP Access**: File upload capability for media management
- ✅ **Auto DJ**: Automated playlist and rotation management

## Installation Commands

Once the repository is set up, users can install AzuraCast with:

```bash
# From YunoHost web admin or
sudo yunohost app install azuracast

# Or from testing branch
sudo yunohost app install https://github.com/YunoHost-Apps/azuracast_ynh/tree/testing --debug
```

## Development Notes

This package bridges AzuraCast's Docker-centric architecture with YunoHost's native packaging system. While this provides the benefits of AzuraCast's robust containerized deployment, it comes with some limitations in YunoHost integration (no SSO/LDAP support, limited backup integration).

The package is designed to be maintainable and follows YunoHost best practices while accommodating the unique requirements of a Docker-based application.

## Next Steps

1. Test the installation on a YunoHost development environment
2. Submit to YunoHost app catalog for review
3. Set up continuous integration for automated testing
4. Create documentation for advanced configuration scenarios
5. Monitor for upstream AzuraCast updates and maintain compatibility