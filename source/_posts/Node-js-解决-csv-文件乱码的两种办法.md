---
title: Node.js 解决 csv 文件乱码的两种办法
date: 2018-03-10 23:56:57
describe: 解决 csv 文件在 macOS 和 Windows 下使用 Excel 打开时中文出现乱码的问题。
tags:
  - Node.js
---

## 问题背景

使用 Excel 打开 csv 文件出现乱码，通常是由于文件编码不匹配导致的。常见的两种编码：

- UTF-8：macOS 和 Node.js 环境的默认编码。macOS 和 Windows 的 Excel 打开是乱码。
- GBK：macOS 和 Windows 的 Excel 打开可以正确显示。在 macOS 的「预览」中显示乱码。

注意 Excel 在 macOS 和 Windows 的行为是一致的。所以 UTF-8 编码的 csv 文件在两个系统的 Excel 中都是乱码，GBK 在两个系统上都正常显示。

## 解法一

由上述结论可知，将 csv 文件保存为 GBK 编码，即可在两个系统的 Excel 中正确显示。Node.js 本身不支持 GBK 编码，可使用 [iconv-lite](iconv-lite) 库。

```javascript
import * as fs from 'fs';
import * as iconv from 'iconv-lite';

fs.writeFileSync(filename, iconv.encode(str, 'gbk'));
```

### 优点

- 使用简单
- macOS 和 Windows 的 Excel 都可以正常显示
- Excel 兼容性好

### 缺点

- 不兼容 UTF-8 环境，比如 macOS 的「预览」中会显示乱码
- Node.js 不支持 GBK

## 解法二

Excel 并非不认识 UTF-8，而是不认识 UTF-8 without BOM。如果 UTF-8 文件带有 BOM 头，则 Excel 可以正确识别和打开。解法二就是给 csv 文件加上 BOM。

```js
import * as fs from 'fs';

fs.writeFileSync(filename, '\ufeff');
fs.appendFileSync(filename, str);
```

### 优点

- 优雅的 UTF-8 编码，兼容性广
- Linux/Node.js 和 Excel 都可以正确打开

### 缺点

- 低版本的 Excel 不支持

## 结论

1. 如果只考虑 Excel 的兼容性，尤其是重点考虑 Windows 平台，使用解法一；
2. 如果解法一不能满足需要，且不用考虑低版本 Excel，使用解法二；
3. 否则考虑使用 xlsx 文件。

[iconv-lite]: https://github.com/ashtuchkin/iconv-lite

