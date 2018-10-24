#!/bin/bash

export JAVA_HOME="/opt/jdk1.8.0_181/"                                                                                                                               
export PATH="$PATH:/opt/jdk1.8.0_181/bin:/opt/jdk1.8.0_181/jre/bin:/opt/hadoop/bin/:/opt/hadoop/sbin/"
export JAVA_CLASSPATH="$JAVA_HOME/jre/lib/"
export JAVA_OPTS="-Dsun.security.krb5.debug=true -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=256M"

apt-get install -y openssl

# Generate self signed certificate
openssl req -x509 -nodes  -days 365 -newkey rsa:1024 -keyout /tmp/jupyterhub.key -out /tmp/jupyterhub.crt

# Give RW rights
chmod 777 -R $NOTEBOOK_DIR
# Generate JupyterHub config
jupyterhub --generate-config

# Configure JupyterHub
sed "s/#c.JupyterHub.admin_access = False/c.JupyterHub.admin_access = True/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

sed "s/#c.JupyterHub.admin_users = set()/c.JupyterHub.admin_users = {'admin'}/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

sed "s/#c.JupyterHub.default_url = ''/c.JupyterHub.default_url = ''/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py
 
sed "s/#c.JupyterHub.ssl_cert = ''/c.JupyterHub.ssl_cert = '/tmp/jupyterhub.crt'/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

sed "s/#c.JupyterHub.ssl_key = ''/c.JupyterHub.ssl_key = '/tmp/jupyterhub.key'/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

if [ "$NOTEBOOK_DIR" != "" ]; then
	export ESCAPED_NOTEBOOK_DIR="${NOTEBOOK_DIR//\//\\/}"

	sed "s/#c.Spawner.notebook_dir = ''/#c.Spawner.notebook_dir = \'$ESCAPED_NOTEBOOK_DIR\'/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
	mv /jupyterhub_config.py.tmp /jupyterhub_config.py
fi

if [ "$USER1" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER1 --gecos "User" $USER1
	# set password
	echo "$USER1:PASSWORD1" | chpasswd
fi

if [ "$USER2" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER2 --gecos "User" $USER2
	# set password
	echo "$USER2:PASSWORD2" | chpasswd
fi

if [ "$USER3" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER3 --gecos "User" $USER3
	# set password
	echo "$USER3:PASSWORD3" | chpasswd
fi

if [ "$USER4" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER4 --gecos "User" $USER4
	# set password
	echo "$USER4:PASSWORD4" | chpasswd
fi


if [ "$USER5" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER5 --gecos "User" $USER5
	# set password
	echo "$USER5:PASSWORD5" | chpasswd
fi

if [ "$USER6" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER6 --gecos "User" $USER6
	# set password
	echo "$USER6:PASSWORD6" | chpasswd
fi


jupyterhub --ip=0.0.0.0 --log-level DEBUG 
