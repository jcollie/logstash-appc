LOGSTASH_VERSION=1.4.2
root=`mktemp -d`
nspawn="systemd-nspawn -D ${root}/rootfs"

git clone --branch CentOS-7 --single-branch --depth 1 https://github.com/CentOS/sig-cloud-instance-images.git ${root}/sig-cloud-instance-images
sudo mkdir ${root}/rootfs
sudo tar --extract --directory=${root}/rootfs --file ${root}/sig-cloud-instance-images/docker/centos-*.tar.xz

sudo ${nspawn} yum -y update
sudo ${nspawn} yum -y install java-1.7.0-openjdk-headless tar python-jinja2 wget
sudo ${nspawn} yum -y clean all

#sudo ${nspawn} groupadd -g 1068 logstash
#sudo ${nspawn} useradd -u 1068 -g 1068 -d /logstash -s /sbin/nologin -M logstash
sudo ${nspawn} mkdir /logstash /logstash/bin /etc/logstash

sudo cp configure.py ${root}/rootfs/logstash/bin/configure.py
sudo cp start.sh ${root}/rootfs/logstash/bin/start.sh
sudo chmod a+x ${root}/rootfs/logstash/bin/start.sh

sudo ${nspawn} wget https://download.elasticsearch.org/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz
sudo ${nspawn} wget https://download.elasticsearch.org/logstash/logstash/logstash-contrib-${LOGSTASH_VERSION}.tar.gz
sudo ${nspawn} tar --file logstash-${LOGSTASH_VERSION}.tar.gz --extract --verbose --directory /logstash --strip-components 1
sudo ${nspawn} tar --file logstash-contrib-${LOGSTASH_VERSION}.tar.gz --extract --ungzip --verbose --directory /logstash --strip-components 1
sudo ${nspawn} rm logstash-${LOGSTASH_VERSION}.tar.gz logstash-contrib-${LOGSTASH_VERSION}.tar.gz
#sudo ${nspawn} chown -R logstash:logstash /logstash /etc/logstash

cp manifest ${root}/manifest

rm -rf ${root}/sig-cloud-instance-images

sudo actool build --overwrite ${root} /tmp/logstash.aci
sudo du -sh ${root}/rootfs
sudo rm -rf ${root}
