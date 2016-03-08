#!/usr/bin/env bash

echo "===================================================================="
echo "Starting bootstrap.sh, now named $0, called with arguments $*"

PROXY_IP=$1
PROXY_PORT=$2
LOCAL_IP=$3

if [ "$2" != "" ]; then
	# echo "SOCKS_SERVER=$PROXY_IP:$PROXY_PORT" >> /etc/profile.d/socksproxy.sh
	echo "===================================================================="
	echo "Proxy Settings:"
	set | grep -i proxy | grep -v _= | sort -f
	sleep 10
	echo "===================================================================="

	# Add proxy to apt-get... requires fiddler chained to ssh
	echo "Acquire::http::proxy \"$http_proxy\";" >> /etc/apt/apt.conf
	echo "Acquire::https::proxy \"$https_proxy\";" >> /etc/apt/apt.conf
	echo "===================================================================="
	echo "Apt Proxy Settings"
	cat /etc/apt/apt.conf || exit 1
	sleep 5	
fi

echo "===================================================================="
echo "Testing internet connectivity..."
wget -q www.google.com > /dev/null
if [ $? -gt 0 ]; then
	echo "No internet access (wget returned error code $?).  Aborting bootstrap.sh"
	exit 1
fi

echo "Internet access is working.  Continuing bootstrap.sh ..."


#echo " -- Installing sources.list... -- "
#rm -f "/etc/apt/sources.list"
#cp "/vagrant/resources/common/sources.list" "/etc/apt/sources.list" 

echo " > -- Updating System -- "
apt-get update || (echo " !!!! Error calling apt-get update.  Aborting bootstrap process. !!!!" && exit 1)
echo " > apt-get update -- finished"

echo "===================================================================="
echo "Running apt-get upgrade ... "
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debian-archive-keyring || exit 1
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes upgrade || exit 1
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debconf-utils || exit 1

echo "===================================================================="
echo " > Setting package installation configuration options "
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root' || exit 1
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root' || exit 1

debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password root' || exit 1
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root' || exit 1
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password root' || exit 1
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root' || exit 1
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root' || exit 1
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' || exit 1

echo "===================================================================="
echo " > Installing packages "

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install \
    zsh \
    apache2 \
    mysql-client mysql-server \
    php5-common php5-cli libapache2-mod-php5 php5-mysql \
    php-apc php5-json php5-mcrypt php5-curl php5-xdebug \
    php5-gd php5-xsl php5-xmlrpc php5-intl \
    phpmyadmin  \
    anacron  \
    git \
    vim \
    emacs \
    screen \
    dos2unix \
    tsocks || exit 1
rm -rf /var/www || exit 1
ln -fs /vagrant/www /var/www || exit 1

echo "===================================================================="
echo " > Installing dotfiles and other local config "

echo " -- Installing bashrc... -- " 
cp "/vagrant/resources/common/bashrc" "/home/vagrant/.bashrc"  || exit 1
chown vagrant:vagrant "/home/vagrant/.bashrc" || exit 1
dos2unix "/home/vagrant/.bashrc" || exit 1
echo " -- Installing zshrc... -- " 
cp "/vagrant/resources/common/zshrc" "/home/vagrant/.zshrc"  || exit 1
chown vagrant:vagrant "/home/vagrant/.zshrc" || exit 1
dos2unix "/home/vagrant/.zshrc" || exit 1
echo " -- Installing emacs conf... -- " 
cp "/vagrant/resources/common/emacs" "/home/vagrant/.emacs"  || exit 1
chown vagrant:vagrant "/home/vagrant/.emacs" || exit 1
dos2unix "/home/vagrant/.emacs" || exit 1
echo " -- Installing php settings... -- " 
cp "/vagrant/resources/common/php-custom.ini" "/etc/php5/mods-available/php-custom.ini"  || exit 1
dos2unix "/etc/php5/mods-available/php-custom.ini" || exit 1
ln -s "/etc/php5/mods-available/php-custom.ini" "/etc/php5/conf.d/php-custom.ini" || exit 1
cp "/vagrant/Vagrantfile" "/vagrant/Vagrantfile.dist" || exit 1
chown vagrant:vagrant "/vagrant/Vagrantfile.dist" || exit 1

echo " -- Enabling apache2 mod_rewrite... -- "
a2enmod rewrite || exit 1

cp "/vagrant/resources/common/gitignore" "/vagrant/.gitignore" || exit 1

echo " -- Restarting apache2... -- "
service apache2 restart || exit 1

guess_ip=`/sbin/ifconfig eth1 | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}'`
echo "View the apache instance by opening a browser to http://$LOCAL_IP"

# The end!
