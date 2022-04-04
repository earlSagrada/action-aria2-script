# 动感Aria2自动安装脚本 🚀

此bash脚本用于自动安装**Aria2 + AriaNg + File Browser + Caddy v2**的官方发布最新的版本。

该架构使用最新的**Caddy v2**作为web服务器。所有相关软件的配置都已经内置在脚本中，并对bt下载进行了优化。使用**File Browser**，您也可以把VPS当作一个云端储存工具，使用效果取决于您的VPS服务质量。

以上四个软件的安装均通过官方提供的下载链接下载最新版本。

## 使用

请使用以下命令来执行脚本：
```
bash <(curl -Lk https://raw.githubusercontent.com/earlSagrada/action-aria2-script/master/install.sh)
```
您将会被要求输入
* 您的域名 和
* ```rpc-secret```密码（用于连接Aria2）

## 系统要求
此脚本开发于Ubuntu 20.10 x64版本，并只在此环境进行了测试。后续将会针对其他环境和使用场景作出改进。

## 功能

* 此脚本假设您拥有一个VPS和指向该VPS的域名。脚本会询问您的域名并将其写入```~/mysite/Caddyfile```，Caddy会自动申请证书和密钥，并储存在```$HOME/.local/share/caddy/certificates/```中。脚本会自动搜索这些文件并将其写入```~/.aria2/aria2.conf```，这让您可以通过HTTPS访问Aria2。

* 此脚本安装了v2.21.1版的File Browser。支持在线播放```.mp4```视频，并支持加载```.vtt```字幕。（字幕需和视频文件在同一文件夹，并有相同文件名）
