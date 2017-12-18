---
title: egg-mongo-native，基于 MongoDB Native Driver
date: 2017-07-04 16:23:05
description: 本插件基于 node-mongodb-native，提供了 MongoDB 官方 driver 及 API。插件对一些常用 API 进行了简单封装以简化使用，同时保留了所有原版属性。适合官方党享用。
tags:
  - MongoDB
  - Egg.js
  - Egg Plugin
---

**2017/12/18 更新** egg-mongo-native 已升级至 Egg.js 2 并支持集群配置。

***

MongoDB 官方为 Node.js 提供了 MongoDB Native Driver。这也是我一直喜欢使用的 MongoDB 库。直接使用官方 API 简单明了，而且也易于学习。

Egg.js 官方提供的 MongoDB 插件基于 Mongoose，所以就自己动手做了这个插件。插件的 API 都是我在实际项目中长期使用的。

**GitHub：**[https://github.com/brickyang/egg-mongo-native](https://github.com/brickyang/egg-mongo-native)

本插件基于 [node-mongodb-native](https://github.com/mongodb/node-mongodb-native)，提供了 MongoDB 官方 driver 及 API。

插件对一些常用 API 进行了简单封装以简化使用，同时保留了所有原版属性。例如，使用原版 API 进行一次查找需要写

```js
db.collection('name')
 .find(query)
 .skip(skip)
 .limit(limit)
 .project(project)
 .sort(sort)
 .toArray();
```

封装后

```js
app.mongo.find('name', { query, skip, limit, project, sort });
```

此插件完全支持 Promise，并强烈推荐使用 async/await。

## 安装

```bash
$ npm i egg-mongo-native --save
```

## 开启插件

```js
// config/plugin.js
exports.mongo = {
  enable: true,
  package: 'egg-mongo-native',
};
```

## 配置

### 单实例

```javascript
// {app_root}/config/config.default.js
exports.mongo = {
  client: {
    host: 'host',
    port: 'port',
    name: 'test',
    user: 'user',
    password: 'password',
  },
};
```

### 集群 （v2.1.0 以上）

```js
// mongodb://host1:port1,host2:port2/name?replicaSet=test
exports.mongo = {
  client: {
    host: 'host1, host2',
    port: 'port1, port2',
    name: 'name',
    option: {
      replicaSet: 'test',
    },
  },
};

// mongodb://host:port1,host:port2/name?replicaSet=test
exports.mongo = {
  client: {
    host: 'host', // or ['host']
    port: 'port1, port2', // or ['port1', 'port2']
    name: 'name',
    option: {
      replicaSet: 'test',
    },
  },
};
```

请到 [config/config.default.js](config/config.default.js) 查看详细配置项说明。

## 使用示例

本插件提供的 API 只是对原版 API 进行了必要的简化，所有属性名称与原版 API 一致。所有针对文档操作的 API，通常接受 2 个参数，第一个参数是 collection 名称，第二个参数是一个对象，属性名即为原版 API 的所有参数。例如，使用原版 API 进行一次插入

```js
db.collection('name').insertOne(doc, options);
```

使用插件 API

```js
const args = { doc, options };
app.mongo.insertOne('name', args);
```

可以看到 `args` 就是包含原版 API 参数的一个对象。

目前插件提供的 API 包括：

```js
connect()      // 不需要用户调用
insertOne()
findOneAndUpdate()
findOneAndReplace()
findOneAndDelete()
insertMany()
updateMany()
deleteMany()
find()
count()
distinct()
createIndex()
listCollection()
createCollection()
```

当然，在任何时候你也都可以使用 `app.mongo.db` 调用所有 API。你可以在这里查看所有 API：[Node.js MongoDB Driver API](http://mongodb.github.io/node-mongodb-native/2.2/api/)。

## 同步与异步

`node-mongodb-native` 所有 API 都支持 Promise，因此你可以自由地以异步或同步方式使用本插件。

### 异步

```js
// Promise
function create(doc) {
  app.mongo.insertOne('name', { doc })
  .then(result => console.log(result))
  .catch(error => console.error(error));
}
```

### 同步

```js
// 使用 async/await
async function create(doc) {
  try {
    const result = await app.mongo.insertOne('name', { doc });
    console.log(result);
  } catch (error) {
    console.error(error);
  }
}
```

如果你使用 `app.mongo.db` 调用原版 API，则也可以使用回调函数。插件封装的 API 不支持回调函数，因为 Promise 和 async/await 更加优雅。

Node.js 7.6 开始已经原生支持 async/await，不再需要 Babel。

## License

[MIT](https://github.com/brickyang/egg-mongo/blob/master/LICENSE)