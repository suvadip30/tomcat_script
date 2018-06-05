#!/bin/bash

## Get Oracle JDK 8 from web
java='jdk-8u171-linux-x64.rpm'
jdk_url="http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/$java"

if [ `rpm -qa | grep jdk1.8-1.8.0_171-fcs.x86_64 | tail -n1 | wc -l` -eq 1 ]; then  ## Check the installation of JDK
   echo 'Jdk already istalled'
   echo '----------------------------'
else
   echo 'Jdk not installed, so installing Jdk'
   echo '---------------------------'
      if [ -f "/tmp/${java}" ]; then   ## check the jdk directory exists or not
         echo 'Oracle jdk exists'
         echo '---------------------------'
         echo `yum localinstall /tmp/$java -y > /dev/null 2>&1`  ##install JDK
      else
         echo 'Oracle jdk doesnt exists, so it is fetching'
         echo '---------------------------'
         `wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/$java" -P /tmp`  ## Fetch the JDK installable
         echo `yum localinstall /tmp/$java -y > /dev/null 2>&1`  ## install JDK
      fi
fi

## Make tomcat dir in /opt and download apache-tomcat tar file
tomcat_tar="https://archive.apache.org/dist/tomcat/tomcat-8/v"$1"/bin/apache-tomcat-"$1".tar.gz"
tomcat_dir="apache-tomcat-"$1""
if [ -d '/opt/tomcat' ]; then  ## Check tomcat directory exists or not
  echo 'Tomcat dir exists in /opt'
    if [ -f "/tmp/${tomcat_dir}.tar.gz" ]; then  ## Check gunzip file exists or not
      echo "Apache tar file with version-"$1" exists"
      echo `tar -zxvf /tmp/${tomcat_dir}.tar.gz -C /opt/tomcat --strip-components=1 > /dev/null 2>&1`  ## Unzip the gunzip file
    else
      echo "Apache tar file with version-"$1" doesn't exists, so it is fetching"
      echo `wget $tomcat_tar -P /tmp`  ## Fetch the tar file
      echo `tar -zxvf /tmp/${tomcat_dir}.tar.gz -C /opt/tomcat --strip-components=1 > /dev/null 2>&1`  ## Untar the gunzip file
    fi
else
  echo 'Tomcat dir doesnt exists'  ## Tomcat directory doesn't exists
  echo `mkdir /opt/tomcat`  ## Make the tomcat directory
    if [ -f "/tmp/${tomcat_dir}.tar.gz" ]; then  ## Check if the gunzip exists or not
      echo "Apache tar file with version-"$1" exists"
      echo `tar -zxvf /tmp/${tomcat_dir}.tar.gz -C /opt/tomcat --strip-components=1 > /dev/null 2>&1`  ## Unzip the gunzip file
    else
      echo "Apache tar file with version-"$1" doesn't exists, so it is fetching"
      echo `wget $tomcat_tar -P /tmp`  ## Fetch the tar file
      echo `tar -zxvf /tmp/${tomcat_dir}.tar.gz -C /opt/tomcat --strip-components=1 > /dev/null 2>&1`  ## Untar the gunzip file
    fi
fi

## change port from default 8080 to 9090 (as later apache is to be installed so tocat is moved to 9090 port)
port='9090'
if [ `cat /opt/tomcat/conf/server.xml | grep 'HTTP/1.1' | grep -oP "(?<=<Connector )[^ ]+" | grep 8080 | tail -n1 | wc -l` -eq 1 ]; then ## Chcek the specific line which contain 8080 port
  echo 'server.xml contains default port, so it is going to change'
  port_line=`cat /opt/tomcat/conf/server.xml | grep 'HTTP/1.1' | grep -oP "(?<=<Connector )[^ ]+" | sed 's/port=//g; s/"//g'`  ## Trim only the port from the specific line
  echo $port_line
  echo `sed -i "s/${port_line}/$port/g" /opt/tomcat/conf/server.xml`  ## Sed to replace the port
else
  echo 'server.xml file contains different port than 8080'
fi

## Create tomcat group
if [ `getent group tomcat | tail -n1 | wc -l` -eq 1 ]; then  ## Check tomcat group exists or not
  echo "tomcat group exists"
  echo '---------------------------'
    if [ `getent passwd tomcat | tail -n1 | wc -l` -eq 1 ]; then  ## Check tomcat user exists or not
       echo 'Tomcat user exists'
       echo '--------------------------'
     else
       echo 'Tomcat User doesnt exists, so it is adding'
       echo '--------------------------'
       `sudo useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat`  ## Add tomcat user
     fi
else
  echo "tomcat group doesnt exists, so it is creating"
  echo '---------------------------'
  echo `groupadd tomcat` ## Add tomcat group
     if [ `getent passwd tomcat | tail -n1 | wc -l` -eq 1 ]; then
       echo 'Tomcat user exists'
       echo '--------------------------'
     else
       echo 'Tomcat User doesnt exists, so it is adding'
       echo '--------------------------'
      `sudo useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat`  ## Add tomcat user
     fi
fi

## Change the permission accordingly
if [ `ls -ltr /opt | grep tomcat | grep -oP root | wc -l` -eq 2 ]; then  ## Check the permission
  echo 'Directory tomcat premission is root, so change it to tomcat group'
  `sudo chgrp -R tomcat /opt/tomcat`  ## Change the group into tomcat group
     if [ -r '/opt/tomcat/conf' ] && [ -x '/opt/tomcat/conf' ]; then   ## Check the permission of conf directory
        echo 'group id and readable is present'
     else
        echo 'group id and readable is not present, so given'
        `sudo chmod -R g+r /opt/tomcat/conf` ## Read permission
        `sudo chmod g+x /opt/tomcat/conf`  ## Execute permission
     fi
else
  echo 'Tomcat dirctory is already in tomcat group'
     if [ -r '/opt/tomcat/conf' ] && [ -x '/opt/tomcat/conf' ]; then ## Check the permission of conf directory
        echo 'group id and readable is present'
     else
        echo 'group id and readable is not present, so given'
        `sudo chmod -R g+r /opt/tomcat/conf`  ## Read permission
        `sudo chmod g+x /opt/tomcat/conf`  ## Execute permission
     fi
fi

if [ `ls -ltr /opt/tomcat/ | grep webapps | grep -oP root | wc -l` -eq 2 ] || [ `ls -ltr /opt/tomcat/ | grep work | grep -oP root | wc -l` -eq 2 ] || [ `ls -ltr /opt/tomcat/ | grep temp | grep -oP root | wc -l` -eq 2 ] || [ `ls -ltr /opt/tomcat/ | grep logs | grep -oP root | wc -l` -eq 2 ]; then  ## Check the ownership of webapps, work, temp and logs dir
  echo 'Directory webapps, work, temp, logs premission is root, so change it to tomcat group'
`chgrp -R tomcat /opt/tomcat/bin`  ## change group of bin dir
`sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/`  ## Change the ownershih to tomcat
else
  echo 'Tomcat subdirctory is already in tomcat group'
fi

## Create systemd unit file
if [ -f '/etc/systemd/system/tomcat.service' ]; then
  echo 'systemd unit file exists'
    if [ `cat /etc/systemd/system/tomcat.service | grep CATALINA | tail -n1 | wc -l` -eq 1 ]; then
       echo 'File content has been found as CATALINA, so skipping'
       `systemctl daemon-reload` ## Reload Systemd to load the Tomcat unit file
       echo 'Tomcat service started'
       `systemctl start tomcat` ## Start the tomcat service
       echo 'Tomcat service got enabled ar boot'
       `systemctl enable tomcat` ## Enable tomcat service enable at boot
    else
       echo 'No CATALINA configuration has been found, so configuration has been written'
#tee -a '/etc/systemd/system/tomcat.service' << END
cat >/etc/systemd/system/tomcat.service <<EOL
# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/java/jdk1.8.0_171-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL
`systemctl daemon-reload` ## Reload Systemd to load the Tomcat unit file
echo 'Tomcat service started'
`systemctl start tomcat` ## Start the tomcat service
echo 'Tomcat service got enabled ar boot'
`systemctl enable tomcat` ## Enable tomcat service enable at boot
fi
else
  echo 'systemd unit file doesnt exists'
  echo `touch /etc/systemd/system/tomcat.service`
    if [ `cat /etc/systemd/system/tomcat.service | grep CATALINA | tail -n1 | wc -l` -eq 1 ]; then
       echo 'File content has been found as CATALINA, so skipping'
       `systemctl daemon-reload` ## Reload Systemd to load the Tomcat unit file
       echo 'Tomcat service started'
       `systemctl start tomcat` ## Start the tomcat service
       echo 'Tomcat service got enabled ar boot'
       `systemctl enable tomcat` ## Enable tomcat service enable at boot
    else
       echo 'No CATALINA configuration has been found, so configuration has been written'
#tee -a '/etc/systemd/system/tomcat.service' << END
cat >/etc/systemd/system/tomcat.service <<EOL
# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/java/jdk1.8.0_171-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL
`systemctl daemon-reload` ## Reload Systemd to load the Tomcat unit file
echo 'Tomcat service started'
`systemctl start tomcat` ## Start the tomcat service
echo 'Tomcat service got enabled ar boot'
`systemctl enable tomcat` ## Enable tomcat service enable at boot
fi
fi

## Deploy war file
if [ -f '/tmp/sample.war' ]; then
  echo 'war file exists'
  echo  `sh /opt/tomcat/bin/shutdown.sh`
  `mv /tmp/sample.war /opt/tomcat/webapps`
  echo `sh /opt/tomcat/bin/startup.sh`
  `systemctl start tomcat`
  `systemctl enable tomcat`
else
  echo 'war file doesnt existsi'
  `wget https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war -P /tmp`
  echo `sh /opt/tomcat/bin/shutdown.sh`
  `mv /tmp/sample.war /opt/tomcat/webapps`
  echo `sh /opt/tomcat/bin/startup.sh`
  `systemctl start tomcat`
  `systemctl enable tomcat`
fi

## Install Apache from Yum
if [ `rpm -qa | grep httpd | tail -n1 | wc -l` -eq 1 ]; then
  echo 'Apache is already installed'
   if [ -f '/etc/httpd/conf/httpd.conf' ]; then
      echo 'httpd configuration file exists'
        if [ `cat /etc/httpd/conf/httpd.conf | grep 'Listen 8080' | tail -n1 | wc -l` -eq 1 ]; then
           echo 'port 8080 already exists'
        else
           echo 'adding 8080 port'
           echo `sed -i '/\Listen 80/a Listen 8080' /etc/httpd/conf/httpd.conf > /dev/null 2>&1` ## Add new line after existing port 80 for 8080
        fi
           `cp index.html login.css /var/www/html` ##copy simple html file
           `systemctl restart httpd`
    fi
else
  echo 'Apache is not installed, so it is installing'
  echo `yum install httpd -y`
    if [ -f '/etc/httpd/conf/httpd.conf' ]; then
      echo 'httpd configuration file exists'
      if [ `cat /etc/httpd/conf/httpd.conf | grep 'Listen 8080' | tail -n1 | wc -l` -eq 1 ]; then
           echo 'port 8080 already exists'
        else
           echo 'adding 8080 port'
           echo `sed -i '/\Listen 80/a Listen 8080' /etc/httpd/conf/httpd.conf > /dev/null 2>&1` ## Add new line after existing port 80 for 8080
        fi
      `cp index.html login.css /var/www/html` ##copy simple html file
     `systemctl restart httpd`
    fi
fi
