#!/bin/bash

# variables
user=false
passwdcheck=false
distupgrade=false
devpackages=false

#echo "Enter R00T password:"
[ `whoami` = root ] || exec su -c $0 root

# create user
echo
echo "Create user + home directory"
echo

while [ $user = false ]
do
    read -p "Username: " uservar

    if [ `id -u $uservar 2>/dev/null || echo -1` -ge 0 ]
    then
        echo "user already exists!"
    else
        useradd -m -d "/home/$uservar" -s /bin/bash -U "$uservar"
        usermod -a -G sudo "$uservar"
        user=true
    fi
done

# set password
while [ $passwdcheck = false ]
do
    CHECK=$(passwd --status $uservar | awk '{print $2}')

    if [ "$CHECK" = "P" ]
    then
        passwdcheck=true
    else
        passwd "$uservar"
    fi
done

# sources
read -p "Do you want clean Debian Stretch?(y/n) " var1

if [ "$var1" = "y" ]
then
    distupgrade=true
fi

# dev packages
read -p "Do you want nodejs & NPM?(y/n) " var2

if [ "$var2" = "y" ]
then
    devpackages=true
fi

if [ $distupgrade = true ]
then
cat /etc/apt/sources.list > sources.bkup1
rm  /etc/apt/sources.list

SOURCE=$(cat <<EOF
deb http://deb.debian.org/debian stretch main
deb-src http://deb.debian.org/debian stretch main

deb http://deb.debian.org/debian stretch-updates main
deb-src http://deb.debian.org/debian stretch-updates main

deb http://security.debian.org/debian-security/ stretch/updates main
deb-src http://security.debian.org/debian-security/ stretch/updates main
EOF
)
echo "$SOURCE" > /etc/apt/sources.list
fi

# init
apt-get update && apt-get upgrade -y
apt autoclean -y  && apt autoremove -y

# basic packages
apt-get install sudo htop git curl wget mpv -y
apt-get install net-tools

# development
if [ $devpackages = true ]
then
    curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
    apt-get install -y nodejs && apt-get install -y npm
    npm install npm@latest -g
fi

## initialize ssh server
apt-get install openssh-server -y && service ssh start

# summary
localip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
echo
echo -e "\033[31;7m user = $uservar"; tput sgr0
echo -e "\033[31;7m home = /home/$uservar"; tput sgr0
echo -e "\033[31;7m host =  $localip"; tput sgr0
echo -e "\033[0m"; tput sgr0
