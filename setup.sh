#!/bin/bash

# Package all update
sudo yum clean all
sudo yum update -y

# Install epel repository
sudo yum install epel-release
sudo sed -i -e 's/enabled=1/enabled=0/g' /etc/yum.repos.d/epel.repo

sudo yum install -y --enablerepo=epel siege

# Install development tools and create settings
sudo yum install -y vim screen git nodejs npm wget mailx
git config --global push.default simple

echo '
:set encoding=utf-8

:syntax on

:set number
:set autoindent
:set showmatch
:set expandtab
:set tabstop=4
:set shiftwidth=4
' > ~/.vimrc

# Setting for SSH
sudo sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
sudo sed -i 's/#StrictModes yes/StrictModes yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' /etc/ssh/sshd_config
sudo sed -i 's/#MaxSessions 10/MaxSessions 5/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sudo sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin without-password/g' /etc/ssh/sshd_config

# Install postfix
sudo systemctl disable sendmail
sudo yum remove -y sendmail

sudo yum install -y postfix
echo 1 | sudo alternatives --config mta
sudo systemctl enable postfix
sudo systemctl enable stop
sudo sed -i 's/#myhostname = host.domain.tld/myhostname = localhost/g' /etc/postfix/main.cf
sudo sed -i 's/#mydomain = domain.tld/mydomain = localdomain/g' /etc/postfix/main.cf
sudo sed -i 's/#myorigin = $myhostname/myorigin = $myhostname/g' /etc/postfix/main.cf
sudo sed -i 's/#inet_interfaces = all/inet_interfaces = all/g' /etc/postfix/main.cf
sudo sed -i 's/inet_interfaces = localhost/#inet_interfaces = localhost/g' /etc/postfix/main.cf
sudo sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
sudo sed -i 's/#in_flow_delay = 1s/in_flow_delay = 1s/g' /etc/postfix/main.cf
sudo sed -i 's/#home_mailbox = Maildir/home_mailbox = Maildir\//g' /etc/postfix/main.cf
sudo sed -i 's/#smtpd_banner = $myhostname ESMTP $mail_name/smtpd_banner = $myhostname ESMTP $mail_name/g' /etc/postfix/main.cf
sudo sed -i 's/#mynetworks_style = host/mynetworks_style = host/g' /etc/postfix/main.cf
sudo systemctl enable start

# Install phpenv
cd /tmp/
git clone https://github.com/CHH/phpenv.git
phpenv/bin/phpenv-install.sh
echo '
export PATH="~/.phpenv/bin:$PATH"
eval "$(phpenv init -)"
' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/CHH/php-build.git ~/.phpenv/plugins/php-build

# Install PHP by phpenv
sudo yum install -y --enablerepo=epel \
  bzip2 bison php-mysql php-mbstring php-pdo php-pear \
  libxml2-devel libcurl-devel libjpeg-devel libpng-devel \
  libmcrypt-devel readline-devel libtidy-devel libxslt-devel
phpenv install 5.6.11
phpenv rehash
phpenv global 5.6.11
sed -i 's/;date.timezone =/date.timezone = Asia\/Tokyo/g' ~/.phpenv/versions/5.6.11/etc/php.ini
ln -s ~/.phpenv/versions/5.6.11/etc/php.ini ~/php.ini

# Install benchmark tool
sudo yum install -y gcc automake autoconf
curl http://byte-unixbench.googlecode.com/files/UnixBench5.1.3.tgz | tar xf
rm -f UnixBench5.1.3.tgz

# Clear tmp files and command logs
rm -rf /tmp/php-build
cat /dev/null > ~/.bash_history
sudo yum clean all

