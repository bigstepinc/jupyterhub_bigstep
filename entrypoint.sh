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
	if [ "$USER1_SECRET_NAME" != "" ]; then
		export PASSWORD1=$(cat $SECRETS_PATH/$USER1_SECRET_NAME)
		echo "$USER1:$PASSWORD1" | chpasswd
		unset PASSWORD1
	fi
fi

if [ "$USER2" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER2 --gecos "User" $USER2
	# set password
	if [ "$USER2_SECRET_NAME" != "" ]; then
		export PASSWORD2=$(cat $SECRETS_PATH/$USER2_SECRET_NAME)
		echo "$USER2:$PASSWORD2" | chpasswd
		unset PASSWORD2
	fi
fi

if [ "$USER3" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER3 --gecos "User" $USER3
	# set password
	if [ "$USER3_SECRET_NAME" != "" ]; then
		export PASSWORD3=$(cat $SECRETS_PATH/$USER3_SECRET_NAME)
		echo "$USER3:$PASSWORD3" | chpasswd
		unset PASSWORD3
	fi
fi

if [ "$USER4" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER4 --gecos "User" $USER4
	# set password
	if [ "$USER4_SECRET_NAME" != "" ]; then
		export PASSWORD4=$(cat $SECRETS_PATH/$USER4_SECRET_NAME)
		echo "$USER4:$PASSWORD4" | chpasswd
		unset PASSWORD4
	fi
fi


if [ "$USER5" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER5 --gecos "User" $USER5
	# set password
	if [ "$USER5_SECRET_NAME" != "" ]; then
		export PASSWORD5=$(cat $SECRETS_PATH/$USER5_SECRET_NAME)
		echo "$USER5:$PASSWORD5" | chpasswd
		unset PASSWORD5
	fi
fi

if [ "$USER6" != "" ]; then
	adduser --quiet --disabled-password --shell /bin/bash --home $NOTEBOOK_DIR/$USER6 --gecos "User" $USER6
	# set password
	if [ "$USER6_SECRET_NAME" != "" ]; then
		export PASSWORD6=$(cat $SECRETS_PATH/$USER6_SECRET_NAME)
		echo "$USER6:$PASSWORD6" | chpasswd
		unset PASSWORD6
	fi
fi



jupyterhub --ip=0.0.0.0 --log-level DEBUG 
