---
title: Node.js 利用异步提升任务处理速度
date: 2019-01-06 18:05:51
description: 调用网络接口并将数据写入本地文件，异步过程的速度是同步过程的 4 倍以上。
tags:
  - Node.js
---

今天在做一个小任务，需要调用阿里云的图像识别接口，对 62662 张照片进行场景识别，并将结果写到本地的 csv 文件中。

因为任务很简单，没想很多就开始码。自从有了 `async/await` 之后，已经很久不写 `callback` 了，所以上手就写成这样：

> 本文所有代码均有简化，只保留关键过程

```javascript
async fetchSceneTags(imagePath) {
    try {
	    const result = await callAliyunAPI(imagePath);
	    return result.errno === 0 ? result.tags : [];
	} catch(error) {
    	return [];        
	}
}

async function writeScene(paths) {
    for (let i = 0, len = paths.length; i < len; i++) {
        await tags = fetchSceneTags(paths[i])
        writeToFile(tags);
        writeStdout(`${i} / ${len}`);
    }
}

function start() {
    const paths = loadPaths();
    writeScene(paths);
}
```

运行起来以后没问题就放着忙别的去了。过了差不多 2 小时回来一看，才跑了 17180 张图，每分钟 144 张。这才意识到同步速度太慢了，于是停掉进程，将代码改成下面这样：

```javascript
fetchSceneTagsAsync(imagePath, callback) {
    callAliyunAPI(imagePath)
        .then(result => {
	    	const tags = result.errno === 0 ? result.tags : [];
	        callback(tags);
    	})
        .catch(error => callback([]));
}

function writeSceneAsync(paths) {
    const callback = tags => {
        await tags = fetchSceneTagsAsync(paths[i])
        writeToFile(tags);
    }
    
    paths.forEach(path => fetchSceneTagsAsync(path, callback));
}

function start() {
    const paths = loadPaths();
    writeSceneAsync(paths);
}
```

跑了一下，直接停摆了。嗯，不能一下把请求全发出去，加一个 Throttle：

```javascript
fetchSceneTagsAsync(imagePath, callback) {
    callAliyunAPI(imagePath)
        .then(result => {
	    	const tags = result.errno === 0 ? result.tags : [];
	        callback(tags);
    	})
        .catch(error => callback([]));
}

function throttle(paths, callback) {
    if(paths.length === 0) return;
    
    const sub = paths.splice(0, 10);
    sub.forEach(path => fetchSceneTagsAsync(path, callback));
	setTimeout(() => throttle(paths, callback), 1000)
}

function writeSceneAsync(paths) {
    const callback = tags => {
        await tags = fetchSceneTagsAsync(paths[i])
        writeToFile(tags);
    }
    
    throttle(paths, callback)
}

function start() {
    const paths = loadPaths();
    writeSceneAsync(paths);
}
```

重新启动服务，观察了一下，大约每分钟处理 568 张图片，速度提升约 4 倍。

