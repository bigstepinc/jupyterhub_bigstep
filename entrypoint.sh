#!/bin/bash

export JAVA_HOME="/opt/jdk1.8.0_191/"                                                                                                                               
export PATH="$PATH:/opt/jdk1.8.0_191/bin:/opt/jdk1.8.0_191/jre/bin:/opt/hadoop/bin/:/opt/hadoop/sbin/"
export JAVA_CLASSPATH="$JAVA_HOME/jre/lib/"
export JAVA_OPTS="-Dsun.security.krb5.debug=true -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=256M"

apt-get install -y openssl

# Generate self signed certificate
openssl req -x509 -nodes  -days 365 -newkey rsa:1024 -keyout /tmp/jupyterhub.key -out /tmp/jupyterhub.crt -config /opt/openssl.conf

# Give RW rights
chmod 777 -R $NOTEBOOK_DIR
chmod 777 -R /bigstep/shared_drives/
# Generate JupyterHub config
jupyterhub --generate-config

# Configure JupyterHub
sed "s/#c.JupyterHub.admin_access = False/c.JupyterHub.admin_access = True/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

sed "s/#c.Authenticator.admin_users = set()/c.Authenticator.admin_users = {'admin'}/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

sed "s/#c.JupyterHub.default_url = ''/c.JupyterHub.default_url = ''/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py
 
sed "s/#c.JupyterHub.ssl_cert = ''/c.JupyterHub.ssl_cert = '\\/tmp\\/jupyterhub.crt'/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

sed "s/#c.JupyterHub.ssl_key = ''/c.JupyterHub.ssl_key = '\\/tmp\\/jupyterhub.key'/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
mv /jupyterhub_config.py.tmp /jupyterhub_config.py

if [ "$NOTEBOOK_DIR" != "" ]; then
	export ESCAPED_NOTEBOOK_DIR="${NOTEBOOK_DIR//\//\\/}"

	sed "s/#c.Spawner.notebook_dir = ''/c.Spawner.notebook_dir = \'$ESCAPED_NOTEBOOK_DIR\'/" /jupyterhub_config.py >> /jupyterhub_config.py.tmp && \
	mv /jupyterhub_config.py.tmp /jupyterhub_config.py
fi

if [ "$ADMIN_PASSWORD" != "" ]; then
	# Add admin user with admin password
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/admin --gecos "User" admin
	# set password
	echo "admin:$ADMIN_PASSWORD" | chpasswd
fi



if [ "$USER1" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER1 --gecos "User" $USER1
	# set password
	if [ "$USER1_PASSWORD" != "" ]; then
		echo "$USER1:$USER1_PASSWORD" | chpasswd
	fi
fi

if [ "$USER2" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER2 --gecos "User" $USER2
	# set password
	if [ "$USER2_PASSWORD" != "" ]; then
		echo "$USER2:$USER2_PASSWORD" | chpasswd
	fi
fi

if [ "$USER3" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER3 --gecos "User" $USER3
	# set password
	if [ "$USER3_PASSWORD" != "" ]; then
		echo "$USER3:$USER3_PASSWORD" | chpasswd
	fi
fi

if [ "$USER4" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER4 --gecos "User" $USER4
	# set password
	if [ "$USER4_PASSWORD" != "" ]; then
		echo "$USER4:$USER4_PASSWORD" | chpasswd
	fi
fi


if [ "$USER5" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER5 --gecos "User" $USER5
	# set password
	if [ "$USER5_PASSWORD" != "" ]; then
		echo "$USER5:$USER5_PASSWORD" | chpasswd
	fi
fi

if [ "$USER6" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER6 --gecos "User" $USER6
	# set password
	if [ "$USER6_PASSWORD" != "" ]; then
		echo "$USER6:$USER6_PASSWORD" | chpasswd
	fi
fi



jupyterhub --ip=0.0.0.0 --log-level DEBUG 
