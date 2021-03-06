FROM centos:centos7

LABEL maintainer="Health Catalyst"
LABEL version="1.0"

## Set a default user. Available via runtime flag `--user docker` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
RUN useradd docker \
	&& mkdir -p /home/docker \
	&& chown docker:docker /home/docker
 
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum clean all

# install packages for authentication with Active Directory
RUN yum -y install which authconfig krb5-workstation krb5-libs pam_krb5 rsync dos2unix samba-common oddjob-mkhomedir sudo ntp; yum clean all

# create /opt/install folder
# RUN mkdir -p /opt/install/

# add script to create keytab file for kerberos authentication with Active Directory
ADD https://healthcatalyst.github.io/InstallScripts/setupkeytab.txt /opt/install/setupkeytab.sh
ADD https://healthcatalyst.github.io/InstallScripts/signintoactivedirectory.txt /opt/install/signintoactivedirectory.sh

ADD https://healthcatalyst.github.io/InstallScripts/replaceconfig.txt /tmp/replaceconfig.sh
ADD https://healthcatalyst.github.io/InstallScripts/wait-for-it.sh /tmp/wait-for-it.sh

RUN dos2unix /tmp/replaceconfig.sh \
    && chmod +x /tmp/replaceconfig.sh \
    && cp /tmp/replaceconfig.sh /usr/local/bin/replaceconfig \
	&& dos2unix /tmp/wait-for-it.sh \
    && chmod +x /tmp/wait-for-it.sh \
    && cp /tmp/wait-for-it.sh /usr/local/bin/wait-for-it \
	&& dos2unix /opt/install/setupkeytab.sh \
    && chmod +x /opt/install/setupkeytab.sh \
	&& dos2unix /opt/install/signintoactivedirectory.sh \
    && chmod +x /opt/install/signintoactivedirectory.sh	

