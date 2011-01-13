#!/bin/bash
# Blueonyx php update script - 0.04
#
## Written by Nelson-Jean Gaasch (JuPiTeR126) for Open Skill ( http://www.openskill.lu ) ; Project started on 23/07/2010
# Huge thanks to george for http://www.mr-webcam.com/viewtopic.php?f=19&t=58&sid=003347d7d6aee967af207b067b2e6506 : 
#
#The MIT License
# Copyright (c) 2010 Nelson-Jean Gaasch - Open Skill
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

#################################
# Variables
#################################
version=php-5.3.5 #Set the version of php here
extrauser=jupiter #Name of your extra user
appelation=openskill # $appelation can NOT be "php" !
#################################
# Exit and bashtrap (control-c)
#	generic exit function
#################################
function f_exit {
rm -f /home/list.tmp
# Perhaps it's too much of restart for apache, but at least I'm sure changes are taken into account
/etc/init.d/httpd restart
service httpd restart
service httpd restart
echo "Program Exited"
exit 0
}
trap bashtrap INT
bashtrap()
{
echo " "
echo "You've hit control-C; terminating the script."
f_exit
}
#################################
# Menu
#	The menu
#################################
function m_menu {
while [ 1 ]
do
	PS3='Choose a number: '
	select choice in "compile" "install" "enableone" "disableone" "exit"
	do
		echo " ";echo "####################################";echo " "
		break
	done
	case $choice in
		compile) 	f_compile ;;
		install)	f_install ;;
		enableone)	f_enableone ;;
		disableone)	f_disableone ;;
		exit)		f_exit ;;
		*)		echo "Wrong choice, same player shoot again" ;;
	esac
done
}
#################################
# changeversion
#	change php version on the fly
#################################
echo "version to be working with is $version"
echo "If that's the version you want, press enter"
echo "If you want another version, type it's number.  !!!Follow $version nomeclature!!!"
read newversion
if [ "$newversion" != "" ]; then
	if [ `echo "$newversion"|wc -m` = "10" ] || [ `echo "$newversion"|wc -m` = "11" ] ; then
		version=$newversion
	else
		echo "Wrong format - $newversion is not the same format as $version"
	fi
fi
echo "Working with $version"
# Don't edit that one, it works just fine
version2=`echo $version | sed 's/\.//g' | cut -f 2 -d"-"`
version3=`echo $version | sed s/php/$appelation/`
echo "version2 = $version2 " && echo "version3 = $version3 "
#################################
# Compile
#	Downloads and compiles the indicated php version2, then makes an archive out of it
#################################
function f_compile {
cd /home/
echo "yum installs dev packages"
#yum install gcc libicu-devel libxml2-devel mysql-devel libpng-devel libjpeg-devel curl-devel bzip2-devel gettext-devel gmp-devel pcre-devel freetype-devel gd-devel aspell-devel db4-devel libxslt-devel php-xml
yum install php-xml
#For the adventurous/lazy (yes to all and quiet):
yum install -yq gcc libicu-devel libxml2-devel mysql-devel libpng-devel libjpeg-devel curl-devel bzip2-devel gettext-devel gmp-devel pcre-devel freetype-devel gd-devel aspell-devel db4-devel libxslt-devel php-xml
#You should change your mirror here
if [ -f $version.tar.gz ]; then
	echo "$version.tar.gz exists, proceeding to extraction.  If extraction fails, consider trying \"rm $version.tar.gz\""
else
	echo "downloading php archive" && wget http://be.php.net/distributions/$version.tar.gz
fi
if [ -d $version3 ]; then
	echo "$version3 allready exists! ; Chosse C to erase it and continue, Choose A to Abort compilation ( !!! Case sensitive!!! )"
	read choice
	if [ "$choice" = "A" ]; then
		echo "Choosed to abort, exiting. . ."
		f_exit
	elif [ "$choice" != "C" ]; then
		echo "$choice is neither C or A ; exiting!"
		f_exit
	fi
fi
echo "deleting $version3 in 5 seconds, hit control-C to abort" && sleep 1 && echo 5 && sleep 1 && echo 4 && sleep 1 && echo 3 && sleep 1 && echo 2 && sleep 1 && echo 1 && sleep 1 && echo "deleting $version3" && rm -Rf 
$version3 && sleep 1
mkdir -p $version3/usr/local/$version2 $version3/etc/$version2 $version3/etc/$version2.d
echo "Uncompressing archive and moving its contents to $version3" && tar -xzf $version.tar.gz &&  mv $version/* $version3 && mv $version/.* $version3
rmdir $version
cd /home
chown -R $extrauser $version3
cd /home/$version3
sudo -u $extrauser ./configure --prefix=/home/$version3/usr/local/$version2 --with-config-file-path=/home/$version3/etc/$version2 --with-config-file-scan-dir=/home/$version3/etc/$version2.d --with-bz2 --with-db4=/usr --with-curl --with-exec-dir=/usr/bin --with-freetype-dir=/usr --with-png --with-png-dir=/usr --enable-gd-native-ttf --without-gdbm --with-gettext --with-gmp --with-iconv --with-jpeg-dir=/usr --with-openssl --with-pspell --with-pcre-regex=/usr --with-zlib --with-layout=GNU --enable-exif --enable-ftp --enable-magic-quotes --enable-sockets --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-wddx --with-kerberos --enable-ucd-snmp-hack --enable-shmop --enable-calendar --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mysql-sock=/var/lib/mysql/mysql.sock --with-libxml-dir=/usr --with-gd=/usr --with-regex=system --with-xsl=/usr --enable-mbstring --with-pic --enable-track-vars --enable-yp --enable-memory-limit --enable-dbx --enable-dio --without-sqlite --with-xml --with-system-tzdata
sudo -u $extrauser gmake
sudo -u $extrauser mkdir -p /home/openskill-$version/usr/local/$version2/share/pear/
cd /home/$version3/usr/local/$version2/share/pear/
#############################
#here's where php.ini get's changed
#############################
line=`cat /etc/php.ini | grep -n open_basedir | grep -v ";" | cut -f 1 -d":"`
bckdata=`cat /etc/php.ini | grep -n open_basedir | grep -v ";" | cut -f 2 -d"="`
echo $line $bckdata
sed $line"s|=.*|= /|" /etc/php.ini > $extrauser-$version2.txt && mv $extrauser-$version2.txt /etc/php.ini && echo "basedir set to /"
tail /etc/php.ini
whoami
echo "waiting 2 secs" && sleep 2
/etc/init.d/httpd restart
service httpd restart
service httpd restart
echo "waiting 2 secs" && sleep 2
lynx -source http://pear.php.net/go-pear | php
sed $line"s|=.*|= $bckdata|" /etc/php.ini > $extrauser-$version2.txt && mv $extrauser-$version2.txt /etc/php.ini && echo "basedir restored to $bckdata"
echo "waiting 2 secs" && sleep 2
/etc/init.d/httpd restart
service httpd restart
service httpd restart
echo "waiting 2 secs" && sleep 2
cd /home
chown -R apache $version3
echo "Compressing new archive" && tar -cpzf $version3"_blueonyx.tar.gz" $version3 && echo "your php has been compressed as /home/$version3"_blueonyx.tar.gz" , you can now proceed with install"
}
#################################
# Install
#	Uncompresses the archive made by f_install and launches the gmake install.  After that, it changes my.conf to old_passwords=0 and moves the php.ini as required
#################################
function f_install {
cd /home/
if [ -f $version3"_blueonyx".tar.gz ]; then
	echo "Extracting archive" && tar -xpzf $version3"_blueonyx.tar.gz" && echo "your php has been uncompressed, starting install"
	cd $version3
	gmake install
	echo "backuping and replacing my.cnf ; coppyng php.ini"
	cp /etc/my.cnf /etc/my.cnf.backup
	echo "[mysqld]" > /etc/my.conf
	echo "datadir=/var/lib/mysql" >> /etc/my.conf
	echo "socket=/var/lib/mysql/mysql.sock" >> /etc/my.conf
	echo "user=mysql" >> /etc/my.conf
	echo "old_passwords=0" >> /etc/my.conf
	echo "[mysqld_safe]" >> /etc/my.conf
	echo "log-error=/var/log/mysqld.log" >> /etc/my.conf
	echo "pid-file=/var/run/mysqld/mysqld.pid" >> /etc/my.conf
	cp php.ini-production /home/$version3/etc/$version2/php.ini && echo "$version is installed, you can now enable it for sites"
else 
	echo "/home/$version3"_blueonyx.tar.gz" doesn't exist! please make/place it there first."
fi
}
#################################
#enableall
#	calls enable function for all sites
#################################
function f_enableall {
echo "This function is quite dangerous, it adds lines without any verification to each of your vhosts includes, You have 5 seconds to hit control-c to abort" && sleep 1 && echo 5 && sleep 1 && echo 4 && sleep 1 && echo 3 && sleep 1 && echo 2 && sleep 1 && echo 1 && sleep 1
for i in `ls /etc/httpd/conf/vhosts/|grep include`
        do
        f_enable $i
        done
}
#################################
#enableone
#	Calls enable function for one site
#################################
function f_enableone {
cd /home/
rm -f list.tmp
echo "Select the site you want to enable : "
for i in `ls /etc/httpd/conf/vhosts/|grep include` 
	do
	echo "$i;`cat /etc/httpd/conf/vhosts/$i |grep ScriptAlias`" >> list.tmp
	done
cat -n list.tmp
read site
i=`sed -n "$site"p list.tmp|cut -f 1 -d";"` && rm -f list.tmp
f_enable $i
}
#################################
#enable
#	code that enables the php for a site
#################################
function f_enable {
i=$1
echo "Enabling $version in $i"
cat /etc/httpd/conf/vhosts/$i |grep -v ScriptAlias|grep -v Action|grep -v AddHandler >> /etc/httpd/conf/vhosts/$i.temp
mv /etc/httpd/conf/vhosts/$i.temp /etc/httpd/conf/vhosts/$i
echo "ScriptAlias /$version2-cgi /home/$version3/usr/local/$version2/bin/php-cgi" >> /etc/httpd/conf/vhosts/$i
echo "Action application/x-http-$version2 /$version2-cgi" >> /etc/httpd/conf/vhosts/$i
echo "AddHandler application/x-http-$version2 .php" >> /etc/httpd/conf/vhosts/$i
echo $version enabled in $i
}
#################################
#disableone
#	Calls disable function for one site
#################################
function f_disableone {
echo "Select the site you want to disable :"
ls /etc/httpd/conf/vhosts/|grep include > list.tmp && cat -n list.tmp
read site
i=`sed -n "$site"p list.tmp` && rm -f list.tmp
cat /etc/httpd/conf/vhosts/$i |grep -v ScriptAlias|grep -v Action|grep -v AddHandler >> /etc/httpd/conf/vhosts/$i.temp && mv /etc/httpd/conf/vhosts/$i.temp /etc/httpd/conf/vhosts/$i && echo "$version disabled on $i"
}
#################################
# Params _ Entry point
#################################
# Program requires a parameter to run, ensures people read!
if [ "$1" = "" ]; then
	echo "Please read the notice at the beginning of this file, and then use it with the right parameters"
	exit
elif [ $1 = "compile" ]; then
        echo "Compilation will start in 3 seconds.";sleep 3
        f_compile
        f_exit
elif [ $1 = "install" ]; then
        echo "Installation starts in 3 secondes.";sleep 3
        f_install
        f_exit
elif [ $1 = "enableall" ]; then
        f_enableall
        f_exit
elif [ $1 = "enableone" ]; then
        f_enableone
        f_exit
elif [ $1 = "disableone" ]; then
        f_disableone
        f_exit
elif [ $1 = "menu" ]; then
        m_menu
fi
