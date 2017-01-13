---
title: CentOS 7 安装 shadowsocks 客户端
toc: true
tags:
  - CentOS
  - Shadowsocks
---

## 前言
最近由于在阿里云从 GitHub 拖代码非常困难，因此萌生了在服务器上使用 shadowsocks 的念头。

本文记录了我在 CentOS 7 上成功安装运行 shadowsocks 客户端的过程。

**本文的过程我已在本地 CentOS 上成功运行，尚未在阿里云实测。**

**给新手：**这里介绍的是安装 shadowsocks **客户端**的过程，也就是让服务器能正常访问 GitHub 的方法。你需要已经有一个 shadowsocks 服务端。

<!--more-->

一般网上找到的「CentOS 安装 shadowsocks」文章多数都是讲安装服务端的。

## 安装 pip

Pip 是 Python 的包管理工具，这里我们用 pip 安装 shadowsocks。

有些文章会介绍用 `yum install -y pip` 安装，我用的是官方一个最小化的 CentOS，没有这个包，所以手动安装。

```
$ curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
$ python get-pip.py
```

## Shadowsocks 客户端

### 安装
```
$ pip install --upgrade pip
$ pip install shadowsocks
```

### 配置

新建配置文件：

```
$ vi /etc/shadowsocks.json
```

填写以下内容

```
{
  "server":"x.x.x.x",             #你的 ss 服务器 ip
  "server_port":0,                #你的 ss 服务器端口
  "local_address": "127.0.0.1",   #本地ip
  "local_port":0,                 #本地端口
  "password":"password",          #连接 ss 密码
  "timeout":300,                  #等待超时
  "method":"aes-256-cfb",         #加密方式
  "workers": 1                    #工作线程数
}
```

### 启动

```
$ nohup sslocal -c /etc/shadowsocks.json /dev/null 2>&1 &
$ echo " nohup sslocal -c /etc/shadowsocks.json /dev/null 2>&1 &" /etc/rc.local   #设置自启动
```

### 测试

运行 `curl --socks5 127.0.0.1:1985 http://httpbin.org/ip`，如果返回你的 ss 服务器 ip 则测试成功：

```
{
  "origin": "x.x.x.x"       #你的 ss 服务器 ip
}
```

## Privoxy

Shadowsocks 是一个 socket5 服务，我们需要使用 Privoxy 把流量转到 http／https 上。

###下载安装文件

```
$ wget http://www.privoxy.org/sf-download-mirror/Sources/3.0.26%20%28stable%29/privoxy-3.0.26-stable-src.tar.gz
$ tar -zxvf privoxy-3.0.26-stable-src.tar.gz
$ cd privoxy-3.0.26-stable
```

privoxy-3.0.26-stable 是目前最新的稳定版，建议在下载前去 [Privoxy 官网下载页](https://www.privoxy.org/sf-download-mirror/Sources/) 检查一下版本。

### 新建用户

Privoxy 强烈不建议使用 root 用户运行，所以我们使用 `useradd privoxy` 新建一个用户.

### 安装
```
$ autoheader && autoconf
$ ./configure
$ make && make install
```

### 配置

```
$ vi /usr/local/etc/privoxy/config
```

找到以下两句，确保没有注释掉

```
listen-address 127.0.0.1:8118 # 8118 是默认端口，不用改，下面会用到
forward-socks5t / 127.0.0.1:0 # 这里的端口写 shadowsocks 的本地端口
```

### 启动

```
$ privoxy --user privoxy /usr/local/etc/privoxy/config
```

## 配置 /etc/profile

编辑：

```
$ vi /etc/profile
```

添加下面两句：

```
export http_proxy=http://127.0.0.1:8118       #这里的端口和上面 privoxy 中的保持一致
export https_proxy=http://127.0.0.1:8118
```

运行以下：

```
$ source /etc/profile
```

测试生效：

```
$ curl www.google.com
```

返回一大堆 HTML 则说明 shadowsocks 正常工作了。

## 后记
如果不能访问，请重启机器，依次打开 shadowsocks 和 privoxy 再测试.

```
$ nohup sslocal -c /etc/shadowsocks.json /dev/null 2>&1 &
$ privoxy --user privoxy /usr/local/etc/privoxy/config
```

如果不需要用代理了，记得把 `/etc/profile` 里的配置注释掉，不然会一直走代理流量。

***
- [Privoxy - Home Page](https://www.privoxy.org/)
- [Shadowsocks - Wikis](https://zh.wikipedia.org/wiki/Shadowsocks)
