#!/bin/bash
set -e
source /pd_build/buildconfig
set -x


# For a JS runtime
# http://nodejs.org/
apt-get install --assume-yes nodejs

# For Nokogiri gem
# http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian
apt-get install --assume-yes libxml2-dev libxslt1-dev

# For RMagick gem
# https://help.ubuntu.com/community/ImageMagick
apt-get install --assume-yes libmagickwand-dev

# Lancuages
apt-get install locales language-pack-zh-hans language-pack-zh-hans-base -y
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
dpkg-reconfigure -f noninteractive locales
echo "export LC_ALL=zh_CN.UTF-8" >> ~/.bashrc
echo "export LANG=zh_CN.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=zh_CN.UTF-8" >> ~/.bashrc

# timezone
echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
if [[ "$final" = 1 ]]; then
	rm -rf /pd_build
else
	rm -f /pd_build/{install,enable_repos,prepare,pups,nginx-passenger,finalize}.sh
	rm -f /pd_build/{Dockerfile,insecure_key*}
fi
