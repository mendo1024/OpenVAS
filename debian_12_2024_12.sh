#!/bin/bash
#set -x
echo "# Versions"
echo "#"
export GVM_LIBS_VERSION=22.10.0
export GVMD_VERSION=23.8.1
export PG_GVM_VERSION=22.6.5
export GSA_VERSION=23.2.1
export GSAD_VERSION=22.11.0
export OPENVAS_SMB_VERSION=22.5.3
export OPENVAS_SCANNER_VERSION=23.8.2
export OSPD_OPENVAS_VERSION=22.7.1
export NOTUS_VERSION=22.6.0
export OPENVAS_DAEMON=23.8.2
echo "#"
echo "# Choosing an Install Prefix"
echo "#"
export INSTALL_PREFIX=/usr/local
echo "#"
echo "# Setting the PATH"
echo "#"
export PATH=$PATH:$INSTALL_PREFIX/sbin
echo "#"
echo "# Creating a Source, Build and Install Directory"
echo "#"
export SOURCE_DIR=$HOME/source
mkdir -p $SOURCE_DIR
export BUILD_DIR=$HOME/build
mkdir -p $BUILD_DIR
export INSTALL_DIR=$HOME/install
mkdir -p $INSTALL_DIR
echo "#"
echo "# Installing Common Build Dependencies and postgresql"
echo "#"
sudo apt update
sudo apt install --no-install-recommends --assume-yes \
  build-essential \
  curl \
  cmake \
  pkg-config \
  python3 \
  python3-pip \
  libcurl4-openssl-dev \
  gnupg
echo "#"
echo "# Importing the Greenbone Signing Key"
echo "#"
curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc
gpg --import /tmp/GBCommunitySigningKey.asc
echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" | gpg --import-ownertrust
echo "#"
echo "# Building and Installing the Components"
echo "#"
echo "## gvm-libs"
echo "#"
sudo apt install -y \
  libglib2.0-dev \
  libgpgme-dev \
  libgnutls28-dev \
  uuid-dev \
  libssh-gcrypt-dev \
  libhiredis-dev \
  libxml2-dev \
  libpcap-dev \
  libnet1-dev \
  libpaho-mqtt-dev \
  sysvbanner
sudo apt install -y \
  libldap2-dev \
  libradcli-dev
curl -f -L https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVM_LIBS_VERSION.tar.gz -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gvm-libs/releases/download/v$GVM_LIBS_VERSION/gvm-libs-v$GVM_LIBS_VERSION.tar.gz.asc -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz
#read
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz
mkdir -p $BUILD_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs
cmake $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var
make -j$(nproc)
mkdir -p $INSTALL_DIR/gvm-libs
make DESTDIR=$INSTALL_DIR/gvm-libs install
sudo cp -rv $INSTALL_DIR/gvm-libs/* /
echo "#"
echo "## gvmd"
echo "#"
sudo apt install -y \
  libglib2.0-dev \
  libgnutls28-dev \
  libpq-dev \
  postgresql-server-dev-15 \
  libical-dev \
  xsltproc \
  rsync \
  libbsd-dev \
  libgpgme-dev
sudo apt install -y --no-install-recommends \
  texlive-latex-extra \
  texlive-fonts-recommended \
  xmlstarlet \
  zip \
  rpm \
  fakeroot \
  dpkg \
  nsis \
  gnupg \
  gpgsm \
  wget \
  sshpass \
  openssh-client \
  socat \
  snmp \
  python3 \
  smbclient \
  python3-lxml \
  gnutls-bin \
  libcjson1 \
  libcjson-dev \
  xml-twig-tools
curl -f -L https://github.com/greenbone/gvmd/archive/refs/tags/v$GVMD_VERSION.tar.gz -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gvmd/releases/download/v$GVMD_VERSION/gvmd-$GVMD_VERSION.tar.gz.asc -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
mkdir -p $BUILD_DIR/gvmd && cd $BUILD_DIR/gvmd
cmake $SOURCE_DIR/gvmd-$GVMD_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLOCALSTATEDIR=/var \
  -DSYSCONFDIR=/etc \
  -DGVM_DATA_DIR=/var \
  -DGVMD_RUN_DIR=/run/gvmd \
  -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
  -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
  -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
  -DLOGROTATE_DIR=/etc/logrotate.d
make -j$(nproc)
mkdir -p $INSTALL_DIR/gvmd
make DESTDIR=$INSTALL_DIR/gvmd install
sudo cp -rv $INSTALL_DIR/gvmd/* /
echo "#"
echo "## pg-gvm"
echo "#"
sudo apt install -y \
  libglib2.0-dev \
  postgresql-server-dev-15 \
  libical-dev
curl -f -L https://github.com/greenbone/pg-gvm/archive/refs/tags/v$PG_GVM_VERSION.tar.gz -o $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz
curl -f -L https://github.com/greenbone/pg-gvm/releases/download/v$PG_GVM_VERSION/pg-gvm-$PG_GVM_VERSION.tar.gz.asc -o $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz.asc $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz
# read
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz
mkdir -p $BUILD_DIR/pg-gvm && cd $BUILD_DIR/pg-gvm
cmake $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION \
  -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
mkdir -p $INSTALL_DIR/pg-gvm
make DESTDIR=$INSTALL_DIR/pg-gvm install
sudo cp -rv $INSTALL_DIR/pg-gvm/* /
echo "#"
echo "# Greenbone Security Assistant"
echo "#"
echo "## GSA"
echo "#"
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-dist-$GSA_VERSION.tar.gz -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-dist-$GSA_VERSION.tar.gz.asc -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz
mkdir -p $SOURCE_DIR/gsa-$GSA_VERSION
tar -C $SOURCE_DIR/gsa-$GSA_VERSION -xvzf $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz
sudo mkdir -p $INSTALL_PREFIX/share/gvm/gsad/web/
sudo cp -rv $SOURCE_DIR/gsa-$GSA_VERSION/* $INSTALL_PREFIX/share/gvm/gsad/web/
echo "#"
echo "## gsad"
echo "#"
sudo apt install -y \
  libmicrohttpd-dev \
  libxml2-dev \
  libglib2.0-dev \
  libgnutls28-dev
curl -f -L https://github.com/greenbone/gsad/archive/refs/tags/v$GSAD_VERSION.tar.gz -o $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gsad/releases/download/v$GSAD_VERSION/gsad-$GSAD_VERSION.tar.gz.asc -o $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz.asc $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz
mkdir -p $BUILD_DIR/gsad && cd $BUILD_DIR/gsad
cmake $SOURCE_DIR/gsad-$GSAD_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DGVMD_RUN_DIR=/run/gvmd \
  -DGSAD_RUN_DIR=/run/gsad \
  -DLOGROTATE_DIR=/etc/logrotate.d
make -j$(nproc)
mkdir -p $INSTALL_DIR/gsad
make DESTDIR=$INSTALL_DIR/gsad install
sudo cp -rv $INSTALL_DIR/gsad/* /
echo "#"
echo "# openvas-smb"
echo "#"
sudo apt install -y \
  gcc-mingw-w64 \
  libgnutls28-dev \
  libglib2.0-dev \
  libpopt-dev \
  libunistring-dev \
  heimdal-dev \
  perl-base
curl -f -L https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVAS_SMB_VERSION.tar.gz -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz
curl -f -L https://github.com/greenbone/openvas-smb/releases/download/v$OPENVAS_SMB_VERSION/openvas-smb-v$OPENVAS_SMB_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz
mkdir -p $BUILD_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb
cmake $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
mkdir -p $INSTALL_DIR/openvas-smb
make DESTDIR=$INSTALL_DIR/openvas-smb install
sudo cp -rv $INSTALL_DIR/openvas-smb/* /
echo "#"
echo "# openvas-scanner"
echo "#"
sudo apt install -y \
  bison \
  libglib2.0-dev \
  libgnutls28-dev \
  libgcrypt20-dev \
  libpcap-dev \
  libgpgme-dev \
  libksba-dev \
  rsync \
  nmap \
  libjson-glib-dev \
  libbsd-dev \
  libcurl4
sudo apt install -y \
  python3-impacket \
  libsnmp-dev
curl -f -L https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS_SCANNER_VERSION.tar.gz -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz
curl -f -L https://github.com/greenbone/openvas-scanner/releases/download/v$OPENVAS_SCANNER_VERSION/openvas-scanner-v$OPENVAS_SCANNER_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz
mkdir -p $BUILD_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner
cmake $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DINSTALL_OLD_SYNC_SCRIPT=OFF \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
  -DOPENVAS_RUN_DIR=/run/ospd
make -j$(nproc)
mkdir -p $INSTALL_DIR/openvas-scanner
make DESTDIR=$INSTALL_DIR/openvas-scanner install
sudo cp -rv $INSTALL_DIR/openvas-scanner/* /
printf "table_driven_lsc = yes\n" | sudo tee /etc/openvas/openvas.conf
printf "openvasd_server = http://127.0.0.1:3000\n" | sudo tee -a /etc/openvas/openvas.conf
echo "#"
echo "# ospd-openvas"
echo "#"
sudo apt install -y \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-packaging \
  python3-wrapt \
  python3-cffi \
  python3-psutil \
  python3-lxml \
  python3-defusedxml \
  python3-paramiko \
  python3-redis \
  python3-gnupg \
  python3-paho-mqtt
curl -f -L https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPD_OPENVAS_VERSION.tar.gz -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz
curl -f -L https://github.com/greenbone/ospd-openvas/releases/download/v$OSPD_OPENVAS_VERSION/ospd-openvas-v$OSPD_OPENVAS_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz
cd $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION
mkdir -p $INSTALL_DIR/ospd-openvas
python3 -m pip install --root=$INSTALL_DIR/ospd-openvas --no-warn-script-location .
sudo cp -rv $INSTALL_DIR/ospd-openvas/* /
echo "#"
echo "# notus-scanner"
echo "#"
sudo apt install -y \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-paho-mqtt \
  python3-psutil \
  python3-gnupg
curl -f -L https://github.com/greenbone/notus-scanner/archive/refs/tags/v$NOTUS_VERSION.tar.gz -o $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz
curl -f -L https://github.com/greenbone/notus-scanner/releases/download/v$NOTUS_VERSION/notus-scanner-v$NOTUS_VERSION.tar.gz.asc -o $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz.asc
gpg --verify $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz.asc $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz
# read
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz
cd $SOURCE_DIR/notus-scanner-$NOTUS_VERSION
mkdir -p $INSTALL_DIR/notus-scanner
python3 -m pip install --root=$INSTALL_DIR/notus-scanner --no-warn-script-location .
sudo cp -rv $INSTALL_DIR/notus-scanner/* /
echo "#"
echo "# openvasd"
echo "#"
sudo apt install -y \
  pkg-config \
  libssl-dev
curl -f -L https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS_DAEMON.tar.gz -o $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON.tar.gz
curl -f -L https://github.com/greenbone/openvas-scanner/releases/download/v$OPENVAS_DAEMON/openvas-scanner-v$OPENVAS_DAEMON.tar.gz.asc -o $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON.tar.gz.asc
gpg --verify $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON.tar.gz.asc $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON.tar.gz
mkdir -p $INSTALL_DIR/openvasd/usr/local/bin
cd $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON/rust/openvasd
cargo build --release
cd $SOURCE_DIR/openvas-scanner-$OPENVAS_DAEMON/rust/scannerctl
cargo build --release
sudo cp -v ../target/release/openvasd $INSTALL_DIR/openvasd/usr/local/bin/
sudo cp -v ../target/release/scannerctl $INSTALL_DIR/openvasd/usr/local/bin/
sudo cp -rv $INSTALL_DIR/openvasd/* /
echo "#"
echo "# greenbone-feed-sync"
echo "#"
sudo apt install -y \
  python3 \
  python3-pip
mkdir -p $INSTALL_DIR/greenbone-feed-sync
python3 -m pip install --root=$INSTALL_DIR/greenbone-feed-sync --no-warn-script-location greenbone-feed-sync
sudo cp -rv $INSTALL_DIR/greenbone-feed-sync/* /
echo "#"
echo "# gvm-tools"
echo "#"
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-setuptools \
  python3-packaging \
  python3-lxml \
  python3-defusedxml \
  python3-paramiko
mkdir -p $INSTALL_DIR/gvm-tools
python3 -m pip install --root=$INSTALL_DIR/gvm-tools --no-warn-script-location gvm-tools
sudo cp -rv $INSTALL_DIR/gvm-tools/* /
echo "#"
echo "# Performing a System Setup"
echo "#"
echo "## Setting up the Redis Data Store"
echo "#"
sudo apt install -y redis-server
sudo cp $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION/config/redis-openvas.conf /etc/redis/
sudo chown redis:redis /etc/redis/redis-openvas.conf
echo "db_address = /run/redis-openvas/redis.sock" | sudo tee -a /etc/openvas/openvas.conf
sudo systemctl start redis-server@openvas.service
sudo systemctl enable redis-server@openvas.service
sudo usermod -aG redis gvm
#sudo apt install -y mosquitto
#sudo systemctl start mosquitto.service
#sudo systemctl enable mosquitto.service
#echo -e "mqtt_server_uri = localhost:1883\ntable_driven_lsc = yes" | sudo tee -a /etc/openvas/openvas.conf
sudo mkdir -p /var/lib/notus
sudo mkdir -p /run/gvmd
sudo chown -R gvm:gvm /var/lib/gvm
sudo chown -R gvm:gvm /var/lib/openvas
sudo chown -R gvm:gvm /var/lib/notus
sudo chown -R gvm:gvm /var/log/gvm
sudo chown -R gvm:gvm /run/gvmd
sudo chmod -R g+srw /var/lib/gvm
sudo chmod -R g+srw /var/lib/openvas
sudo chmod -R g+srw /var/log/gvm
sudo chown gvm:gvm /usr/local/sbin/gvmd
sudo chmod 6750 /usr/local/sbin/gvmd
echo "#"
echo "# Feed Validation"
echo "#"
curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc
export GNUPGHOME=/tmp/openvas-gnupg
mkdir -p $GNUPGHOME
gpg --import /tmp/GBCommunitySigningKey.asc
echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" | gpg --import-ownertrust
export OPENVAS_GNUPG_HOME=/etc/openvas/gnupg
sudo mkdir -p $OPENVAS_GNUPG_HOME
sudo cp -r /tmp/openvas-gnupg/* $OPENVAS_GNUPG_HOME/
sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME
echo "%gvm ALL = NOPASSWD: /usr/local/sbin/openvas" | sudo tee -a /etc/sudoers
echo "#"
echo "# Setting up PostgreSQL"
echo "#"
sudo apt install -y postgresql postgresql-server-dev-15
sudo systemctl start postgresql@15-main
sudo -u postgres createuser -DRS gvm
sudo -u postgres createdb -O gvm gvmd
sudo -u postgres psql gvmd -c "create role dba with superuser noinherit; grant dba to gvm;"
echo "#"
echo "# Setting up an Admin User & Setting the Feed Import Owner"
echo "#"
adminpwd=`sudo -u gvm /usr/local/sbin/gvmd --create-user=admin|awk -F\' '{print $2}'`
echo "Admin password: " $adminpwd
echo $adminpwd>/tmp/pgadmin.pwd
export amdinpwd
adminid=`sudo -u gvm /usr/local/sbin/gvmd --get-users --verbose | awk '{print $2}'`
export adminid
sudo -u gvm /usr/local/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $adminid
echo "#"
echo "# Setting up Services for Systemd"
echo "#"
echo "## ospd-openvas.service"
echo "#"
cat << EOF > $BUILD_DIR/ospd-openvas.service
[Unit]
Description=OSPd Wrapper for the OpenVAS Scanner (ospd-openvas)
Documentation=man:ospd-openvas(8) man:openvas(8)
After=network.target networking.service redis-server@openvas.service openvasd.service
Wants=redis-server@openvas.service openvasd.service
ConditionKernelCommandLine=!recovery

[Service]
Type=exec
User=gvm
Group=gvm
RuntimeDirectory=ospd
RuntimeDirectoryMode=2775
PIDFile=/run/ospd/ospd-openvas.pid
ExecStart=/usr/local/bin/ospd-openvas --foreground --unix-socket /run/ospd/ospd-openvas.sock --pid-file /run/ospd/ospd-openvas.pid --log-file /var/log/gvm/ospd-openvas.log --lock-file-dir /var/lib/openvas --socket-mode 0o770 --notus-feed-dir /var/lib/notus/advisories
SuccessExitStatus=SIGKILL
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

sudo cp -v $BUILD_DIR/ospd-openvas.service /etc/systemd/system/

#echo "#"
#echo "## notus-scanner.service"
#echo "#"
#cat << EOF > $BUILD_DIR/notus-scanner.service
#[Unit]
#Description=Notus Scanner
#Documentation=https://github.com/greenbone/notus-scanner
#After=mosquitto.service
#Wants=mosquitto.service
#ConditionKernelCommandLine=!recovery
#
#[Service]
#Type=exec
#User=gvm
#RuntimeDirectory=notus-scanner
#RuntimeDirectoryMode=2775
#PIDFile=/run/notus-scanner/notus-scanner.pid
#ExecStart=/usr/local/bin/notus-scanner --foreground --products-directory /var/lib/notus/products --log-file /var/log/gvm/notus-scanner.log
#SuccessExitStatus=SIGKILL
#Restart=always
#RestartSec=60
#
#[Install]
#WantedBy=multi-user.target
#EOF
#sudo cp -v $BUILD_DIR/notus-scanner.service /etc/systemd/system/
echo "#"
echo "## gvmd.service"
echo "#"
cat << EOF > $BUILD_DIR/gvmd.service
[Unit]
Description=Greenbone Vulnerability Manager daemon (gvmd)
After=network.target networking.service postgresql.service ospd-openvas.service
Wants=postgresql.service ospd-openvas.service
Documentation=man:gvmd(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=exec
User=gvm
Group=gvm
PIDFile=/run/gvmd/gvmd.pid
RuntimeDirectory=gvmd
RuntimeDirectoryMode=2775
ExecStart=/usr/local/sbin/gvmd --foreground --osp-vt-update=/run/ospd/ospd-openvas.sock --listen-group=gvm
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF
sudo cp -v $BUILD_DIR/gvmd.service /etc/systemd/system/
echo "#"
echo "## gsad.service"
echo "#"
cat << EOF > $BUILD_DIR/gsad.service
[Unit]
Description=Greenbone Security Assistant daemon (gsad)
Documentation=man:gsad(8) https://www.greenbone.net
After=network.target gvmd.service
Wants=gvmd.service

[Service]
Type=exec
User=gvm
Group=gvm
RuntimeDirectory=gsad
RuntimeDirectoryMode=2775
PIDFile=/run/gsad/gsad.pid
ExecStart=/usr/local/sbin/gsad --foreground --listen=127.0.0.1 --port=9392 --http-only
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
Alias=greenbone-security-assistant.service
EOF
sudo cp -v $BUILD_DIR/gsad.service /etc/systemd/system/
echo "#"
echo "## openvasd.service"
echo "#"
cat << EOF > $BUILD_DIR/openvasd.service
[Unit]
Description=OpenVASD
Documentation=https://github.com/greenbone/openvas-scanner/tree/main/rust/openvasd
ConditionKernelCommandLine=!recovery
[Service]
Type=exec
User=gvm
RuntimeDirectory=openvasd
RuntimeDirectoryMode=2775
ExecStart=/usr/local/bin/openvasd --mode service_notus --products /var/lib/notus/products --advisories /var/lib/notus/advisories --listening 127.0.0.1:3000
SuccessExitStatus=SIGKILL
Restart=always
RestartSec=60
[Install]
WantedBy=multi-user.target
EOF
sudo cp -v $BUILD_DIR/openvasd.service /etc/systemd/system/
echo "#"
echo "## systemctl reload"
echo "#"
sudo systemctl daemon-reload
echo "#"
echo "## Downloading the Data"
echo "#"
sudo /usr/local/bin/greenbone-feed-sync
echo "#"
echo "# Starting the Greenbone Community Edition Services"
echo "#"
#sudo systemctl start notus-scanner
sudo systemctl start ospd-openvas
sudo systemctl start gvmd
sudo systemctl start gsad
#sudo systemctl enable notus-scanner
sudo systemctl enable ospd-openvas
sudo systemctl enable gvmd
sudo systemctl enable gsad
echo "#"
echo "Spawning the browser"
echo "#"
xdg-open "http://127.0.0.1:9392" 2>/dev/null >/dev/null &
