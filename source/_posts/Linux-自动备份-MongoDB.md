---
title: Linux 自动定时备份 MongoDB
date: 2017-03-02 18:01:52
description: 本文介绍在 Linux 系统下，使用 mongodump 命令自动定时备份数据库的方法。
tags:
 - MongoDB
---

本文介绍在 Linux 系统下，使用 `mongodump` 命令自动定时备份数据库的方法。

## mongodump

`mongodump` 是 MongoDB 提供的一个工具，用于备份数据库，配合使用 `mongorestore` 恢复工具使用。这套工具适合小型应用或开发环境。

运行 `mongodump` 和 `mongorestore` 时需要读取正在运行的数据库实例，因此会影响数据库性能。一方面是运行时需要占用系统资源，另一方面，运行这两个命令时数据库会强制通过内存读取所有数据，可能导致读取的不常用数据覆盖常用数据，从而影响数据库日常运行的性能。

*2.2及以上版本的 `mongodump` 数据格式与低版本**不兼容**，因此请勿使用高版本工具备份低版本数据。*

`mongodump` 不会备份 `local` 数据库。

直接运行 `mongodump` 命令，默认备份本地运行在27017端口下的 MongoDB 实例中的所有数据库（`local` 除外），并在当前目录下生成 `dump/` 路径存放备份文件。

你也可以使用以下命令指定备份的数据库位置、端口、输出文件位置、备份数据库和文档：

```
mongodump --host mongodb.example.net --port 27017 --out /data/backup/ --db test --collection myCollection
```

## 命令脚本

首先我们要创建一个执行备份工作的脚本。在 `~/crontab/` 下新建一个 `.sh` 文件：

```
mkdir -p ~/crontab
vi ~/crontab/mongod_bak.sh
```

写入以下内容：

```
#!/bin/sh
DUMP=mongodump
OUT_DIR=/data/backup/mongod/tmp   // 备份文件临时目录
TAR_DIR=/data/backup/mongod       // 备份文件正式目录
DATE=`date +%Y_%m_%d_%H_%M_%S`    // 备份文件将以备份时间保存
DB_USER=<USER>                    // 数据库操作员
DB_PASS=<PASSWORD>                // 数据库操作员密码
DAYS=14                           // 保留最新14天的备份
TAR_BAK="mongod_bak_$DATE.tar.gz" // 备份文件命名格式
cd $OUT_DIR                       // 创建文件夹
rm -rf $OUT_DIR/*                 // 清空临时目录
mkdir -p $OUT_DIR/$DATE           // 创建本次备份文件夹
$DUMP -u $DB_USER -p $DB_PASS -o $OUT_DIR/$DATE  // 执行备份命令
tar -zcvf $TAR_DIR/$TAR_BAK $OUT_DIR/$DATE       // 将备份文件打包放入正式目录
find $TAR_DIR/ -mtime +$DAYS -delete             // 删除14天前的旧备份
```

这个脚本完成了备份、打包、删除一定时间之前旧备份的工作。注意其中的 `user` 需要具有对希望备份的数据库具有 `find` 操作权限。

保存好脚本后别忘了将它设为可执行：

```
chmod +x ~/crontab/mongod_bak.sh
```

现在你可以试着执行一下 `./mongod_bak.sh`，就会在备份文件夹中看到打包好的备份数据了。

## 自动运行

备份脚本写好之后，就需要让它自动运行。直接使用 Linux 的 `crontab` 命令即可：

```
vi /etc/crontab
```

在底部添加：

```
0 2 * * * root ~/crontab/mongod_bak.sh
```

这一行表示在每天凌晨02:00以 root 身份运行备份数据库的脚本。然后重启 crond 使其生效：

```
/bin/systemctl restart  crond.service
chkconfig crond on    // 设为开机启动
```

至此，一个自动运行的备份脚本就设置好了。以后每天凌晨02:00都会有一份新鲜的备份文件放在指定目录中，并且会自动删除14天前的旧备份。

## 恢复备份

[使用 mongorestore 恢复 MongoDB 备份](https://brickyang.github.io/2017/04/11/%E4%BD%BF%E7%94%A8-mongorestore-%E6%81%A2%E5%A4%8D-MongoDB-%E5%A4%87%E4%BB%BD/)

***

- [Back Up and Restore with MongoDB Tools](https://docs.mongodb.com/manual/tutorial/backup-and-restore-tools/)
- [Cron - Wikipedia](https://zh.wikipedia.org/zh-hans/Cron)