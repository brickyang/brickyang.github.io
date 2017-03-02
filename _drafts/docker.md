---
layout: "post"
title: "Docker"
date: "2017-01-13 23:57"
---

  ### Docker 的基本概念
  Docker 最重要的3个基本概念：

  #### Docker Client
  在后台负责执行你的 Docker 命令，这里我们不需要关心它。

  #### Docker Image
  Docker image（镜像）是 Docker Container 的基础。我们使用 image 来产生一个个实际运行的 container。不准确地说，你可以把它理解成一个安装包，使用它「安装」出具体使用的软件。

  我们使用 `Docker build` 命令来创建一个 image。

  #### Docker Container
  Docker container（容器）是我们实际使用的应用或操作的环境。Container 是用 image 创建的，专业点说就是「container 是 image 的实例」。

  我们使用 `Docker run` 命令来创建一个 container。

  这里我们说「用 Docker 建立开发环境」，就是指创建一个打包好 Node.js 和 Hexo 的 image。每次当我们准备更新博客时，只需要用这个 image 运行一个 container，就拥有了一个安装好 Node.js 和 Hexo 的虚拟机。当你做完所有事后，只需要关掉虚拟机即可。一切干干净净。
