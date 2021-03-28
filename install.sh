#!/bin/bash

### Usage: Install latest Aria2 + AriaNg + File Browser + Caddy v2
### Author: Bojan Fu
### Date: 28-03-2021

# TODO: After restart:
# caddy start
# aria2c --conf-path=/etc/aria2/aria2.conf -D
# systemctl start filebrowser



# Check if softwares have been installed
function check_if_installed() {
	echo '------------------------------------------------------'
	echo 'Installing newest Aria2 + AriaNg + File Browser + Caddy v2...'
	echo 'Check if softwares have been installed...'

	if [ -e '/usr/bin/caddy' ]
	then
		echo 'Caddy has been installed!'
		echo 'Caddy version:' $(caddy version)
		caddy_installed=1
	else
		caddy_installed=0
		echo 'Caddy will be installed from the latest version.'
	fi

	if [ -e '/usr/bin/aria2c' ]
	then
		echo 'Aria2 has been installed!'
		echo 'Aria2 version:' $(aria2c --version)
		aria2_installed=1
	else
		aria2_installed=0
		echo 'Aria2 will be installed from the latest version.'
	fi

	if [ -e '/usr/local/bin/filebrowser' ]
	then
		echo 'File Browser has been installed!'
		echo 'File Browser version:' $(filebrowser version)
		filebrowser_installed=1
	else
		filebrowser_installed=0
		echo 'File Browser will be installed from the latest version.'
	fi
	
	echo ''------------------------------------------------------''
	
	if [ caddy_installed = 1 ] && [ aria2_installed -eq 1 ] && [ filebrowser_installed -eq 1 ]
	then
		exit 1
	fi
	printf "\n"
	sleep 3
}


function preparation() {
	if [ -e '/usr/bin/apt' ]
	then
		echo 'Preparing installation...'
		sudo apt update
		# sudo apt upgrade -y
		sudo apt -y install curl gcc make bzip2 gzip wget unzip zip tar
	else
		echo -e '\e[7mThis version of script is dependent on apt!'
	fi
	printf "\n"
	sleep 3
}


# Install Caddy
function install_caddy() {
	sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
	curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -
	curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee -a /etc/apt/sources.list.d/caddy-stable.list
	sudo apt update
	sudo apt install caddy

	cd ~
	mkdir mysite
	cd mysite
	touch Caddyfile
	mkdir src
	
	read -p 'Please entre the domain name you have registered, whose A/AAAA record points to this IP address: ' domain_name
	read -p 'Please entre your email address for tls: ' email_address
	echo 'http://'$domain_name '{
	        redir https://'$domain_name'
	}

	https://'$domain_name '{
	        root * src
	        encode zstd gzip
	        file_server browse
	}

	https://file.'$domain_name' {
	        tls 'email_address'
	        encode zstd gzip
	        reverse_proxy localhost:8080
	}' >> Caddyfile
	echo 'Caddy has been installed successfully!'
	printf "\n"
	sleep 3
}


# Start Caddy
function start_caddy() {
	caddy stop
	caddy start
	echo 'Please wait for 20 seconds...'
	printf "\n"
	sleep 20
}


# Install AriaNg
function install_ariang() {
	cd ~/mysite/
	wget https://github.com/mayswind/AriaNg/releases/download/1.2.1/AriaNg-1.2.1.zip
	unzip AriaNg-1.2.1.zip -d src
	echo 'AriaNg has been installed successfully!'
	printf "\n"
	sleep 3
}


# Install aria2
function install_aria2() {

	sudo apt install aria2
	mkdir /etc/aria2
	touch /etc/aria2/aria2.session
	touch /etc/aria2/aria2.conf
	touch /etc/aria2/aria2_1.conf

	read -p 'Entre the rpc-secret you wish to use: ' secret 

	echo '# 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
	dir=/root/Download/
	# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
	# disk-cache=32M
	# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
	# 预分配所需时间: none < falloc ? trunc < prealloc
	# falloc和trunc则需要文件系统和内核支持
	# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
	file-allocation=trunc
	# 断点续传
	continue=true
	 
	# 是否启用 RPC 服务的 SSL/TLS 加密,
	# 启用加密后 RPC 服务需要使用 https 或者 wss 协议连接
	rpc-secure=true
	# 在 RPC 服务中启用 SSL/TLS 加密时的证书文件(.pem/.crt)
	rpc-certificate=
	# 在 RPC 服务中启用 SSL/TLS 加密时的私钥文件(.key)
	rpc-private-key=

	## 下载连接相关 ##
	 
	# 最大同时下载任务数, 运行时可修改, 默认:5
	max-concurrent-downloads=5
	# 同一服务器连接数, 添加时可指定, 默认:1
	max-connection-per-server=8
	# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
	# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
	min-split-size=10M
	# 单个任务最大线程数, 添加时可指定, 默认:5
	split=16
	# 整体下载速度限制, 运行时可修改, 默认:0
	#max-overall-download-limit=0
	# 单个任务下载速度限制, 默认:0
	#max-download-limit=0
	# 整体上传速度限制, 运行时可修改, 默认:0
	max-overall-upload-limit=1024K
	# 单个任务上传速度限制, 默认:0
	max-upload-limit=100K
	# 禁用IPv6, 默认:false
	disable-ipv6=true
	 
	## 进度保存相关 ##
	 
	# 从会话文件中读取下载任务
	input-file=/etc/aria2/aria2.session
	# 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
	save-session=/etc/aria2/aria2.session
	# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
	save-session-interval=60
	 
	## RPC相关设置 ##
	 
	# 启用RPC, 默认:false
	enable-rpc=true
	# 允许所有来源, 默认:false
	rpc-allow-origin-all=true
	# 允许非外部访问, 默认:false
	rpc-listen-all=true
	# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
	# event-poll=select
	# RPC监听端口, 端口被占用时可以修改, 默认:6800
	rpc-listen-port=6800
	# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
	rpc-secret='$secret'
	 
	## BT/PT下载相关 ##
	 
	# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
	#follow-torrent=true
	# BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
	listen-port=51413
	# 单个种子最大连接数, 默认:55
	#bt-max-peers=55
	# 打开DHT功能, PT需要禁用, 默认:true
	enable-dht=true
	# 打开IPv6 DHT功能, PT需要禁用
	#enable-dht6=false
	# DHT网络监听端口, 默认:6881-6999
	#dht-listen-port=6881-6999
	# 本地节点查找, PT需要禁用, 默认:false
	#bt-enable-lpd=false
	# 种子交换, PT需要禁用, 默认:true
	enable-peer-exchange=false
	# 每个种子限速, 对少种的PT很有用, 默认:50K
	#bt-request-peer-speed-limit=50K
	# 客户端伪装, PT需要
	peer-id-prefix=-TR2770-
	user-agent=Transmission/2.77
	# 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
	seed-ratio=0
	# 强制保存会话, 即使任务已经完成, 默认:false
	# 较新的版本开启后会在任务完成后依然保留.aria2文件
	#force-save=true
	# BT校验相关, 默认:true
	#bt-hash-check-seed=true
	# 继续之前的BT任务时, 无需再次校验, 默认:false
	bt-seed-unverified=true
	# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
	bt-save-metadata=true
	' > /etc/aria2/aria2_1.conf

	# Delete possible spaces appearing at the beginning of each line
	sed 's/^[ \t]*//g' /etc/aria2/aria2_1.conf > /etc/aria2/aria2.conf
	rm aria2_1.conf

	# Find the TLS cert and key
	cd $HOME/.local/share/caddy/certificates

	certpath=`find "$(pwd)" -name "*crt"`
	echo 'certpath:' $certpath
	sed -i "s_rpc-certificate=_rpc-certificate=${certpath}_g" /etc/aria2/aria2.conf
	keypath=`find "$(pwd)" -name "*key"`
	echo 'keypath:' $keypath
	sed -i "s_rpc-private-key=_rpc-private-key=${keypath}_g" /etc/aria2/aria2.conf

	cd ~
	wget -O /tmp/trackers_best.txt https://api.xiaoz.org/trackerslist/
	tracker=$(cat /tmp/trackers_best.txt)
	tracker="bt-tracker="${tracker}
	echo $tracker >> /etc/aria2/aria2.conf
	
	echo 'Aria2 has been installed successfully!'
	printf "\n"
	sleep 4
}


# Allow the ports used in aria2c
function set_free_ports() {
	echo 'Allowing the ports used in aria2c...'
	printf "\n"

	sudo ufw allow 6080/tcp
	sudo ufw allow 6081/tcp
	sudo ufw allow 6800/tcp
	sudo ufw allow 6998/tcp
	sudo ufw allow 51413/tcp
	sleep 3
}


# Pkill and start aria2c as daemon
function start_aria2c() {
	pkill aria2c
	aria2c --conf-path=/etc/aria2/aria2.conf -D # Check aria2 conf and run as daemon
	echo 'Aria2 is now runnning as daemon...'
	printf "\n"
	sleep 3
}


# Install File Browser
function install_file_browser() {
	curl -fsSL https://filebrowser.org/get.sh | bash
	mkdir /root/Download/
	#filebrowser -r /root/Download/

	mkdir /etc/filebrowser/
	cd /etc/filebrowser/
	touch /etc/filebrowser/config.json
	echo '{
	    "address":"0.0.0.0",
	    "database":"/etc/filebrowser/filebrowser.db",
	    "log":"/var/log/filebrowser.log",
	    "port":8080,
	    "root":"/root/Download",
	    "username":"admin"
	}' > /etc/filebrowser/config.json
	#nohup filebrowser -c /etc/filebrowser/config.json &


	touch /lib/systemd/system/filebrowser.service
	echo '[Unit]
	Description=File Browser
	After=network.target

	[Service]
	ExecStart=/usr/local/bin/filebrowser -c /etc/filebrowser/config.json

	[Install]
	WantedBy=multi-user.target' > /lib/systemd/system/filebrowser.service
	systemctl daemon-reload
	echo 'File Browser has been installed successfully!'
	printf "\n"
	sleep 3
}


# Start File Browser
function start_file_browser() {
	echo 'Starting File Browser...'
	systemctl enable filebrowser.service
	systemctl start filebrowser.service
	printf "\n"
	sleep 3
}


# Report installation and version
function report_installation() {
	printf "\n"
	echo '------------------------------------------------------'
	echo 'Installation finished!'
	echo $(caddy version)
	echo $(aria2c --version)
	echo $(filebrowser version)
	echo '------------------------------------------------------'
	echo 'Use your domain to access the AriaNg and domain:8081 to access File Browser.'
	echo 'Aria2 rpc-secret token:' $secret
	echo 'File Browser: initial Username: admin. Password: admin.'
	echo '------------------------------------------------------'
}


check_if_installed
preparation
install_caddy
start_caddy
install_ariang
install_aria2
set_free_ports
start_aria2c
install_file_browser
start_file_browser
report_installation



#filebrowser config init
#cd /etc/filebrowser/
#filebrowser users add bojan shinchan13bojan
#filebrowser config set --baseurl /root/Download/

#sed -i '/bt-tracker.*/'d ~/.aria2/aria2.conf

#filebrowser users update bojan --perm.admin
