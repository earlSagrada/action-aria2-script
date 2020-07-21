# ACTION Aria2 Script 🚀

This bash script is for auto-installation of the latest official version of **Aria2 + AriaNg + File Browser + Caddy v2**.

The bundle uses **Caddy v2** as web server. The configuration file is preseted in the script and is best for bt-download and online watching. With **File Browser**, this can be also used as a cloud storage, depending the quality of your VPS.

All the resources of installation are from official links, providing the newest function support.

## README in other languages
* [中文介绍](./README/README_zh-Hans.md)

## Usage
Use this line of command to execute the script:
```
bash <(curl -Lk https://raw.githubusercontent.com/earlSagrada/action-aria2-script/master/install.sh)
```
You'll be asked to entre your domain name and `rpc-secret` token.

## System Requirements
NOTE: This is a newly developed script especially for Ubuntu 20.04 x64 VPS machine. Further adaptation will be added for other environment and usage scenario.

## Features
* This script assumes you have a VPS and a domain name pointing to the IP address of the VPS. The script will ask for the domain name and write into `~/mysite/Caddyfile`. Caddy will then automatically get a certification and a key for you, which will be stored in `$HOME/.local/share/caddy/certificates/`. The `.crt` and `.key` will be searched and filled into `/etc/aria2/aria2.conf`, which will enable you to access aria2 through HTTPS.

* The latest File Browser version is v2.5.0, which is capable of playing `mp4` video online and auto-detect and use `.vtt` subtitle in the same folder.
