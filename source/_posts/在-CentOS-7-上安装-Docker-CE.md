---
title: 在 CentOS 7 上安装 Docker
date: 2017-04-12 15:48:19
description: 记录在 CentOS 7 服务器上安装 Docker CE 的过程。
tags:
  - ContOS
  - Docker
---

本文记录在 CentOS 7 服务器上安装 Docker CE 的过程。Docker CE 是社区版，即免费版。Docker EE 是企业版，即收费版。

**Docker CE 和 EE 版的安装过程不尽相同，本过程仅适用于 CE 版。**

## 系统要求

需要 CentOS 7 64-bit。

## 卸载旧版本

```
sudo yum remove docker docker-common container-selinux docker-selinux docker-engine
```

## 安装 Docker

有两种方法安装 Docker，这里使用最常用的仓库安装方法。

### 建立仓库

1. 安装 `yum-utils`

```
sudo yum install -y yum-utils
```

2. 建立仓库

```
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### 安装和使用

1. 更新 `yum` 包索引

```
sudo yum makecache fast
```

2. 安装最新版 Docker（**如需安装指定版本请跳过此步**）

```
sudo yum install docker-ce
```

3. 安装指定版本 Docker

```
sudo yum install docker-ce-<VERSION>
```

> 建议在生产服务器上总是安装指定版本 Docker。先使用 `yum list` 命令列出所有版本。
>
> ```
> yum list docker-ce.x86_64  --showduplicates |sort -r
> ```
>
> 这个命令安版本号排序列出 Docker CE 的二进制包。

4. 启动 Docker

```
sudo systemctl start docker
```

### 升级 Docker

如果希望升级 Docker，首先运行 `sudo yum makecache fast`，然后按照以上步骤重新选择新版本安装。

***

- [Get Docker for CentOS](https://docs.docker.com/engine/installation/linux/centos/#install-docker)