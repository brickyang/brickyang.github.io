---
title: 如何在 Egg.js 中使用 TypeScript
date: 2017-12-21 12:42:29
description: Egg.js 本身不是用 TypeScript 写的，但是你可以自由地在自己的 Egg 应用中使用 TypeScript。
tags:
  - Egg.js
  - TypeScript
---

**2019-01-13：**本文发表时，Egg.js 还没有官方的 TypeScript 实践指南。目前 Egg 的 TypeScript 生态已经有了很大的改进，包括：

- egg-ts-helper 自动生成声明文件
- 内置 ts-node 实现开发阶段加载 `.ts` 文件并内存编译（不输出 `.js` 文件）
- `egg-init` 支持 `--type=ts`
- 改进错误堆栈

这些改进令使用 TypeScript 开发 Egg 应用更加方便。本文中提到的一些操作细节不再必要，不过这些概念仍然有效，对 TypeScript 新人也仍有价值。GitHub 上的 [egg-ts-boilerplate](https://github.com/brickyang/egg-ts-boilerplate) 也已经更新。



Egg.js 本身不是用 TypeScript 写的，但是它提供了 `index.d.ts` 文件，因此我们可以很方便地在自己的 Egg 应用中使用 TypeScript。

在 Egg.js 中使用 TypeScript 的模板：[egg-ts-boilerplate](https://github.com/brickyang/egg-ts-boilerplate)。

这个模板展示了如何用 TypeScript 写诸如 `controller`、`service`、配置、数据库、定时任务和扩展等 Egg 应用的概念。

本文是对这个模板的扩展阅读，主要是解释一些基本概念，帮助对 TypeScript 不是很熟悉的用户理解。

## TypeScript

TypeScript 的核心思想是，用 TypeScript 语法写 `.ts` 文件，然后由编译器将其编译成 `.js` 文件。根据 TypeScript 语法，如果你使用了一个类，就需要先声明它，否则编译器「不认识」它，就无法通过编译。

在自己的 Egg 应用中使用 TypeScript，核心就是「如何让编译器认识 Egg 库中的类」，解决方法就是 `index.d.ts`。

## index.d.ts

在 Egg 中用 TypeScript，其实关键就是 `index.d.ts` 文件。

`index.d.ts` 就像 C/C++ 中的 `.h` 文件。它的作用可以简单理解为就是声明类和库的 API。

虽然 Egg 不是用 TypeScript 写的，但是它提供了 `index.d.ts` 文件，因此当你在自己的应用中 `import xxx from 'egg'` 时，编译器知道如何处理。

在 Egg 中使用 TypeScript 的第一个核心问题：Egg 的 `index.d.ts` 文件，Egg 的作者和社区已经帮我们解决了（虽然还不是很完善）。

第二个问题是：我们应用中的 `controller` 和 `service` 等，是从 Egg 的 `Controller` 、`Service` 等类继承来的。这些自定义内容在 Egg 的 `index.d.ts` 中是没有的，所以需要写在**自己的** `index.d.ts` 文件中。

```typescript
// egg-ts-boilerplate/index.d.ts

declare module 'egg' {
  export interface Application {
    config: EggAppConfig & DefaulConfig;
    bar: string;
  }

  export interface IController {
    home: HomeController;
  }

  export interface IService {
    home: HomeService;
  }
}
```

这是 `egg-ts-boilerplate` 的 `index.d.ts`。现在编译器就「认识」`app.config`、`app.bar`、`controller.home` 和 `service.home` 了。

基本上，理解并搞定 `index.d.ts`，就可以自由地用 TypeScript 写 Egg 应用了。

## 模块解析策略

熟悉 TypeScript 的模块解析策略有助于在遇到 `not found module` 错误时排查问题。

TypeScript 支持两种策略：`class` 和 `node`。`egg-ts-boilerplate` 使用的是 `node` 模式（在 `.tsconfig.json` 中定义）。

其解析顺序与 Node.js 类似。假设在 `/root/src/moduleA.ts` 中 `import 'moduleB'`，则解析顺序是：

1. `/root/src/node_modules/moduleB.ts`
2. `/root/src/node_modules/moduleB.tsx`
3. `/root/src/node_modules/moduleB.d.ts`
4. `/root/src/node_modules/moduleB/package.json` 中的 `types` 属性
5. `/root/src/node_modules/moduleB/index.ts`
6. `/root/src/node_modules/moduleB/index.tsx`
7. `/root/src/node_modules/moduleB/index.d.ts`
8. `/root/node_modules/moduleB.ts`
9. `/root/node_modules/moduleB.tsx`
10. `/root/node_modules/moduleB.d.ts`
11. `/root/node_modules/moduleB/package.json` 中的 `types` 属性
12. `/root/node_modules/moduleB/index.ts`
13. `/root/node_modules/moduleB/index.tsx`
14. `/root/node_modules/moduleB.index.d.ts`
15. `/node_modules/moduleB.ts`
16. `/node_modules/moduleB.tsx`
17. `/node_modules/moduleB.d.ts`
18. `/node_modules/moduleB/package.json` 中的 `types` 属性
19. `/node_modules/moduleB/index.ts`
20. `/node_modules/moduleB/index.tsx`
21. `/node_modules/moduleB/index.d.ts`

基本思路就是先查找同名文件，如果没有就把模块名当文件夹处理。如果所有路径都找不到，就会抛出 `not found` 错误。

注意这里 `import 'moduleB'` 是非相对路径。如果是相对路径，则会按照指定路径去解析。

详细说明可以阅读文档：[Module Resolution](https://www.typescriptlang.org/docs/handbook/module-resolution.html)

## 编译文件的位置

通常使用 TypeScript 时，会把 `.ts` 文件放在 `/src` 文件夹，然后把编译得到的 `.js` 文件放在 `/build` 文件夹，应用实际运行的是 `/build` 文件夹中的 `.js` 文件。

Egg 对应用文件夹结构有强制性要求，所以在 `.tsconfig.json` 中没有指定输出文件夹，因此编译得到的 `.js` 文件会和 `.ts` 文件位于同目录下。

如果你使用 VSCode，编译后在 Explorer 中是看不到 `.js` 文件的（在 Finder 中可以看到）。因为在 `/.vscode/setting.json` 中设置了 `.js` 文件不可见（同时不可见的还有 `node_module/` 等）。如果你使用其他编辑器，可以做相应设置。