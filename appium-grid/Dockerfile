FROM hub.c.163.com/workhardsmile/citest:appium-base

MAINTAINER Frank Wu <workhard_smile@163.com>

ENV DEBIAN_FRONTEND=noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# openjdk-8-jdk
#   Java
# ca-certificates
#   SSL client
# tzdata
#   Timezone
# zip
#   Make a zip file
# unzip
#   Unzip zip file
# curl
#   Transfer data from or to a server
# wget
#   Network downloader
# libqt5webkit5
#   Web content engine (Fix issue in Android)
# libgconf-2-4
#   Required package for chrome and chromedriver to run on Linux
# xvfb
#   X virtual framebuffer
#==================
RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install \
    tzdata \
    libqt5webkit5 \
    libgconf-2-4 \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

#===============
# Set JAVA_HOME
#===============
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
    PATH=$PATH:$JAVA_HOME/bin

#==================================
# Fix Issue with timezone mismatch
#==================================
ENV TZ="US/Pacific"
RUN echo "${TZ}" > /etc/timezone

#===============
# Expose Ports
#---------------
# 4723
#   Appium port
#===============
EXPOSE 4723

#====================================================
# Scripts to run appium and connect to Selenium Grid
#====================================================
COPY \
  ./entry_point.sh \
  ./generate_config.sh \
    /root/
RUN chmod +x /root/entry_point.sh && \
    chmod +x /root/generate_config.sh

#========================================
# Run xvfb and appium server
#========================================
CMD ["/root/entry_point.sh"]
