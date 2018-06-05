## Install Tomcat and Apache
----------------
	- Installation of Oracle JDK V8
	- Installation of Tomcat from .tar.gz file
	- Deployment of Sample.war file
	- Make Tomcat systemctl enabled on boot
	- Install Apache from Yum
	- Configure Apache in port 8080
	- Include index.html file to view the output

## Steps in tomcat.sh script 
-----------------
	- Download the Oracle JDK from web link
	- Check and install the Oracle JDK
	- Create a tomcat folder in /opt directory if not present.
	- Download tomcat gunzip file and extract fom it to /opt/tomcat directory
	- Check all the permission and ownership of the subdirectories in tomcat directory
	- Assign read and execute permission to bin directory to specific script like startup and shutdown.sh
	- Check the ownership of the directories, if not present assign with tomcat user and group
	- Modify default port 8080 with 9090 in configuration file - /opt/tomcat/conf/server.xml (This port need to be changed because apache will listen to 8080)
	- Deploy configuration file for tomcat.service.
	- Download and deploy Sample.war file into webapps directory by maintaing the process of running shutdown and startup script.
	- Start the tomcat service and enable at boot level.
	- Install Apache from Yum command
	- Include port 8080 in the configuration file situated in - /etc/httpd/conf/httpd.conf - didn't remove the default port 80 - so it can be access from both the port
	- Start the apache service.
