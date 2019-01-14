---
title: 国内下载安装 Puppeteer 的方法
date: 2019-01-14 22:17:08
description: 因为某些原因国内难以正常安装 Puppeteer。
tags:
---

执行 `npm install puppeteer` 时，有可能会报错，也有可能不会。只要没看到类似：

```bash
Downloading Chromium r609904 - 82.7 Mb [===                 ] 16% 990.3s
```

这样的输出，就是没有下载 Chromium。启动 app 后就会报错：

```bash
nodejs.Error: Chromium revision is not downloaded. Run "npm install" or "yarn install"
```

此时再执行这些命令通常没有用，因为能下载第一次安装时就会下载了。

# 方法一（推荐）

在终端执行：

```bash
PUPPETEER_DOWNLOAD_HOST=https://storage.googleapis.com.cnpmjs.org npm install puppeteer
```

改用 cnpm 的镜像地址下载。此方法基本无副作用。

# 方法二

改用 `puppeteer-cn`：

```bash
npm install --save puppeteer-cn
```

需要本地 Chrome 版本大于 59。详见：[puppeteer-cn](https://npm.taobao.org/package/puppeteer-cn)

# 方法三

用 cnpm 安装：

```bash
cnpm install puppeteer
```

cnpm 是淘宝的镜像源，出于一些原因，我个人已经不再使用。关于 cnpm：[cnpm](https://github.com/cnpm/cnpm)

# 方法四

最复杂的手动安装，建议没事别折腾。参考：[手动下载 Chrome，解决 puppeteer 无法使用问题](https://marxjiao.com/2018/08/26/puppeteer-install/)