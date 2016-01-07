#!/bin/sh -f
# How to test: ovs-vsctl -V

#Remove old version ovs
aptitude remove openvswitch-common openvswitch-datapath-dkms openvswitch-controller openvswitch-pki openvswitch-switch -y

#Install new version ovs
wget http://openvswitch.org/releases/openvswitch-2.3.0.tar.gz
tar zxvf openvswitch-2.3.0.tar.gz
cd openvswitch-2.3.0
./configure --prefix=/usr --with-linux=/lib/modules/`uname -r`/build
make
make install
make modules_install
rmmod openvswitch
depmod -a

# Say goodbye to openvswitch-controller
/etc/init.d/openvswitch-controller stop
update-rc.d openvswitch-controller disable

#Start new version ovs
/etc/init.d/openvswitch-switch start
ovsdb-tool create /usr/local/etc/openvswitch/conf.db /usr/local/share/openvswitch/vswitch.ovsschema
ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach --log-file
ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach