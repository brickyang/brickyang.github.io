---
title: 利用 SSH 端口转发进行微信开发本地调试
date: 2018-06-16 10:25:23
description: 使用微信 JS-SDK 进行网页开发时，微信要求绑定域名白名单，并仅接受该域名发起的请求，不便于本地开发调试。利用 SSH 端口转发可以解决这个问题。
tags:
  - SSH
  - WeChat
---



使用微信 JS-SDK 进行网页开发时，微信要求绑定域名白名单，并仅接受该域名发起的请求，不便于本地开发调试。利用 SSH 端口转发可以解决这个问题。

**前提条件**

- 一台服务器（云服务器或虚拟空间皆可，配置没要求，不需要运行服务）
- 一个域名（使用国内空间可能需要备案）

**使用方法**

1. 域名解析至服务器
2. 在微信后台绑定域名
3. 在本地通过 SSH 将远程端口映射到本地

**命令**

```
$ ssh -R <REMOTE_PORT>:127.0.0.1:<LOCAL_PORT> <USER>@<SERVER_IP>
```

可以看到就是在 SSH 登录服务器的命令上，增加了 `-R` 参数，在远程端口和本地端口之间建立隧道，服务器上该端口的所有请求都会转发到本地端口上，实现了在本地接受公网请求进行调试的需要。

**Trouble Shooting**

如果登录服务器后看到：

```
$ Warning: remote port forwarding failed for listen port <PORT>
```

说明服务器端口被占用，此时先登出服务器，重新普通登录（无端口转发）并关闭占用端口的进程：

```bash
$ ssh <USER>@<SERVER_IP>
$ sudo netstat -plant | grep <PORT> // 查看哪些进程占用了端口
$ kill -9 <PID>
$ ssh -R <REMOTE_PORT>:127.0.0.1:<LOCAL_PORT> <USER>@<SERVER_IP>
```

