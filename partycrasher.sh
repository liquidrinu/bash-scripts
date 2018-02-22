#!/bin/bash

# variables
user=false
passwdcheck=false
distupgrade=false
devpackages=false
profilepkg=false

# insert packages
APT=('sudo' 'htop' 'git' 'curl' 'wget' 'mpv' 'net-tools');

# Root privileges
echo -e "\e[96m";
[ `whoami` = root ] || exec su -c $0 root

# adduser
echo -e "\e[38;5;82m"
read -p "Add user? (y/n) " var1

if [ "$var1" = "y" ]
then
    echo "Create user + home directory"

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
fi

# sources
read -p "Do you want clean Debian Stretch?(y/n) " var2

if [ "$var2" = "y" ]
    then
        distupgrade=true
fi

# dev packages
read -p "Do you want nodejs & NPM?(y/n) " var3

if [ "$var3" = "y" ]
    then
        devpackages=true
fi

# custom packages (profile)
echo -e "\e[95m"
read -p  "Custom Profile packages? o_o (y/n)" profile

if [ "$profile" = "y" ]
    then
        profilepkg=true
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

if [ $profilepkg = true ]
then
for i in {14..21} {21..76} ; do echo -en "\e[38;5;${i}m#\e[0m" ; done ; echo
# init
    apt-get update && apt-get upgrade -y
    apt autoclean -y  && apt autoremove -y

# personal profile packages
echo -e "\e[38;5;198m \n"
echo -e "Profile Packages"
echo -e "\n"
    apt-get install ${APT[@]} -y
fi
echo -e "\033[0m";

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
echo -e "\e[93m";

if [ "$user" = "true" ] 
then
echo -e "user =  $uservar                            ";
echo -e "home =  /home/$uservar                      ";
fi
echo -e "host =  $localip               ";
echo -e "\033[0m";
