---
title: Docker 中如何设置 container 的时区
date: 2017-03-16 12:52:18
description: 使用官方镜像时，默认时区往往是 UTC，和国内有8个小时时差，所以需要我们手动修改时区。
tags:
  - Docker
  - Linux
---

最近在使用 Docker 时发现 container 中的时区是 UTC。这是因为我的基础镜像是官方的 `node:7.6` 。Docker Store 上的官方镜像基本上都默认是 UTC 时区，需要我们手动设置一下。

## Dockerfile

如果你使用 Dockerfile 制作自己的镜像，那么只需要在 Dockerfile 中加入下面两句就可以了：

```
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
```

> `echo "Asia/Shanghai" > /etc/timezone` 和 `dpkg-reconfigure -f noninteractive tzdata` 是 Ubuntu 修改时区的命令。Docker 默认使用 Ubuntu 系统。如果你的自定义镜像使用的是其他发行版，那么这里的命令也要改变。

在制作镜像过程中可以看到以下输出：

```
Current default time zone: 'Asia/Shanghai'
Local time is now:      Thu Mar 16 12:51:35 CST 2017.
Universal Time is now:  Thu Mar 16 04:51:35 UTC 2017.
```

修改成功。以后这个镜像生成的 container 就都是北京时间了。

## 同步主机时区

利用 `volume` 可以在启动一个 container 时指定使用主机的时区文件，就可以把 container 的时区与主机同步：

```
docker run -v /etc/localtime:/etc/localtime <IMAGE:TAG>
```

这种方法的好处是不会修改镜像，适合需要在不同时区主机上运行的场景。

## 运行中的 container

如果你不想新建镜像或者重启 container，那么也可以直接进入 container 修改。执行：

```
docker exec -it <CONTAINER NAME> bash
```

进入 container 之后执行：

```
echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
```

> 仍然需要注意不同发行版命令的差别。

这里和 Docker 有关的主要是如何进入 container，进去之后该怎么操作就怎么操作。