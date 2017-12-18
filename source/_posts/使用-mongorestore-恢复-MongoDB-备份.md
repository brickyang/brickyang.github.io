---
title: 使用 mongorestore 恢复 MongoDB 备份
date: 2017-04-11 18:37:03
description: 本文介绍使用 mongorestore 命令恢复 MongoDB 数据库备份文件。
tags:
  - MongoDB
---

上一篇[《Linux 自动定时备份 MongoDB》](https://brickyang.github.io/2017/03/02/Linux-%E8%87%AA%E5%8A%A8%E5%A4%87%E4%BB%BD-MongoDB/)文章中说了如何使用 `mongodump` 命令备份 MongoDB 数据库。这里说明一下如何使用 `mongorestore` 命令恢复备份。

`mongodump` 和 `mongorestore` 是一对命令，分别用于备份和恢复数据。

`mongorestore` 命令默认将 `/dump` 文件夹（同时也是 `mongodump` 的默认备份文件夹）下的所有数据恢复到相应的数据库中，也接受很多选项控制备份操作。

我们最常用一个的操作需求是：

> 将指定的备份文件恢复到指定数据库的指定文档

其对应的命令是

```
mongorestore -d <DATABASE> -c <COLLECTION> <PATH>
```

`PATH` 就是要恢复的数据文件夹或文件，用于恢复整个数据库或指定恢复一个列的数据。

***

- [mongorestore](https://docs.mongodb.com/manual/reference/program/mongorestore/)