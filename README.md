# Greenbone OpenVAS
[Open Vulnerability Assessment Scanner](https://www.openvas.org/) | [Greenbone Community Edition](https://greenbone.github.io/docs/latest/index.html)

The script will build and install a fully functional Greenbone Community Edition in the following steps:
- Install the software required to build, install and run the scanner tools
- Download and verify the source code
- Build and install the scanner tools
- Configure systemd services

Prerequisites:
- Debian 11

The script consists of hundreds of Linux one-liners taken from the [original guide in the Greenbone documentation](https://greenbone.github.io/docs/latest/22.4/source-build/index.html) without any error checking logic.

Steps to install and run:
```bash
# Make user gvm and make the current user a member of gvm
sudo useradd -r -M -U -G sudo -s /usr/sbin/nologin gvm
sudo usermod -aG gvm $USER

# Make the shell aware of new group
exec su -l $USER

# Clone this repository and run the install script
git clone https://github.com/mendo1024/OpenVAS.git
OpenVAS/debian_11_2024_Jan.sh
```
Expect 10-20 minutes of scrolling text.

The `admin` password is in file `/tmp/pgadmin.pwd`
