#!/bin/bash

# 搭建 TFTP 服务
apt-get update
apt-get install -y atftpd
mkdir /tftpboot
chmod 777 /tftpboot

sed -e 's/^USE_INETD=true/USE_INETD=false/g' -i /etc/default/atftpd
sed -e 's/\/srv\/tftp/\/tftpboot/g' -i /etc/default/atftpd

cp /root/tools/exe_nc /tftpboot/exe_nc

/etc/init.d/atftpd start

# 启动 ssh 服务
/etc/init.d/ssh start

# 配置网卡
tunctl -t tap0
ifconfig tap0 192.168.2.1/24

# 进入 qemu 镜像目录
cd /root/images

/usr/bin/expect<<EOF
set timeout 10000
spawn qemu-system-arm -M vexpress-a9 -kernel vmlinuz-3.2.0-4-vexpress -initrd initrd.img-3.2.0-4-vexpress -drive if=sd,file=debian_wheezy_armhf_standard.qcow2 -append "root=/dev/mmcblk0p2" -net nic -net tap,ifname=tap0,script=no,downscript=no -nographic

expect "debian-armhf login:"
send "root\r"
expect "Password:"
send "root\r"

expect "root@debian-armhf:~# "
send "ifconfig eth0 192.168.2.2/24\r"

#expect "root@debian-armhf:~# "
#send "echo 0 > /proc/sys/kernel/randomize_va_space\r"

expect "root@debian-armhf:~# "
send "scp root@192.168.2.1:/root/squashfs-root.tar.gz /root/squashfs-root.tar.gz\r"
expect {
    "(yes/no)? " { send "yes\r"; exp_continue }
    "password: " { send "root\r" }
}

expect "root@debian-armhf:~# "
send "tar xzf squashfs-root.tar.gz && rm squashfs-root.tar.gz\r"
expect "root@debian-armhf:~# "
send "mount -o bind /dev ./squashfs-root/dev && mount -t proc /proc ./squashfs-root/proc\r"

expect "root@debian-armhf:~# "
send "scp -r root@192.168.2.1:/root/tools /root/squashfs-root/tools\r"
expect {
    "(yes/no)? " { send "yes\r"; exp_continue }
    "password: " { send "root\r" }
}

expect "root@debian-armhf:~# "
send "chroot squashfs-root/ sh\r"
expect "# "
send "tddp task start\r"

expect eof
EOF
