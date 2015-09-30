FROM ubuntu:14.04
MAINTAINER Matt Ho

#--[ DO NOT MODIFY BELOW THIS POINT ]------------------------------------

ENV GOCD_VERSION 15.2.0
ENV GOCD_BUILD   2248
ENV GOCD_DEB     go-server-${GOCD_VERSION}-${GOCD_BUILD}.deb

# install oracle jdk 7
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:webupd8team/java -y

RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# install dependencies
RUN apt-get update && apt-get install -y curl wget unzip 

# install go-agent
ENV DAEMON             N
ENV GO_SERVER_PORT     8153
ENV GO_SERVER_SSL_PORT 8154
ENV SERVER_WORK_DIR    /var/lib/go-server
RUN curl -L -o /tmp/${GOCD_DEB} http://download.go.cd/gocd-deb/${GOCD_DEB} && \
	dpkg -i /tmp/${GOCD_DEB} && \
	rm -f /tmp/${GOCD_DEB} ; \
	rm -f /etc/default/go-server

VOLUME /etc/go
VOLUME /var/lib/go-server
VOLUME /var/log/go-server	 

#--[ BUILD DEPENDENCIES ]------------------------------------------------

# install all the vcs tools
RUN apt-get update && apt-get install -y git subversion bzr mercurial
ADD ssh/config /root/.ssh/config

# install docker
RUN apt-get update && apt-get install -y docker.io

# add java to path
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${JAVA_HOME}/bin

#--[ NGINX FRONT END ]---------------------------------------------------

RUN apt-get update && apt-get install -y nginx 
RUN echo 'daemon off;' >> /etc/nginx/nginx.conf
ADD openssl_answers.txt /tmp/openssl_answers.txt
RUN mkdir -p /etc/nginx/ssl && \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt < /tmp/openssl_answers.txt && \
		rm /tmp/openssl_answers.txt
ADD nginx/sites-available/default /etc/nginx/sites-available/default

#--[ SUPERVISORD TO BIND THEM ALL ]--------------------------------------

RUN apt-get update && apt-get install -y supervisor
ADD supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 443

CMD ["/usr/bin/supervisord"]




