---
title: 从 GitHub 到 GitLab，打造私有项目 CI/CD 工作流
date: 2018-01-04 12:17:07
description: 与 GitHub 相比，GitLab 内置对 CI/CD 的支持，而且对私有项目完全免费，更适合个人使用。
tags:
  - GitLab
  - Docker
---

一直用 GitHub 托管所有代码，包括一些非开源的商业项目，同时也一直在寻找最佳的 CI/CD 工作流配置。作为个人开发者，主要的需求有两个：

1. 不自建服务；
2. 成本越低越好，最好免费。

## GitHub 的不足

GitHub 首先对私有仓库收费，新政策 7 美元/月还算便宜，比以前按仓库数量收费好得多。最主要的问题还是没有很合适的 CI/CD 服务。Travis CI 只对公开项目免费，对私有项目收费且价格不菲；CircleCI 对私有项目免费，但配置比较难用，也不是很满意。

## GitLab 的优势

在试用了 GitLab 后发现以上问题都可以解决：

1. 无限制私有仓库
2. 内置 CI/CD 服务，且配置简单易用，支持 Docker
3. 内置私有的 Docker 仓库
4. 免费

我已经重新梳理了项目的开发-测试-部署流程，并把所有个人非开源项目都转移到 GitLab，把 GitHub 账户重新降级为 Free。

## 工作流

我目前采用的工作流依托两个工具：

1. Git：版本控制和管理
2. Docker：部署和运行应用

我自己目前主要是个人开发，多人开发流程需要做一些调整。

1. 在本地 `dev` 分支上开发和单元测试
2. 测试通过后，`merge` 到本地 `master` 分支
3. 对 `master` 分支打 `tag`，`push` 到 GitLab
4. GitLab 自动进行构建和测试
5. 测试通过后自动 `build image`，并将其 `push` 到 GitLab 提供的免费 Docker 仓库
6. 手动登录服务器，`pull image`，替换 `container`

其中 4、5 两步在 GitLab 上自动完成，并且只对 tag 的推送进行操作。

## 实例

这是一个 TypeScript 的 Node.js 项目的实例。

### .gitlab-ci.yml

```yml
build:
  only:
    - tags
  stage: build
  image: node:8
  script:
    - npm install
    - npm run tsc
  artifacts:
    paths:
      - node_modules/
      - app/**/*.js
      - app/*.js
      - config/*.js
      - app.js
    expire_in: 1 day

test:
  only:
    - tags
  stage: test
  image: node:8
  services:
    - redis:3.2
  script:
    - npm run test-ci

docker:image:
  only:
    - tags
  stage: deploy
  image: docker
  services:
    - docker:dind
  script:
    - docker version
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME .
    - echo $GITLAB_USER_LOGIN
    - echo $CI_JOB_TOKEN
    - echo $CI_REGISTRY
    - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME
```

GitLab 的 CI 过程分为多个 `job`，每个 `job` 彼此独立，可以实现复杂的 CI 过程，比如多环境并行测试。像这样一个简单的项目其实不需要分 `job`，因为每个 `job` 都要新建环境，浪费时间。

GitLab 的文档非常简单易懂，这里只说几个值得注意的点：

1. 在 `build` 中产生的文件（安装的依赖和编译文件），需要通过 `artifacts` 传递给后续的 `jobs`，否则后续 `jobs` 的环境中是没有这些文件的。
2. 所有环境和数据库都在不同的 Docker `container` 中，所以连接数据库不能用 `Host: localhost`，而要用 `Host: redis`、`Host: mysql` 这种。
3. `$CI_REGISTRY` 这种是 GitLab 的内置变量，可以直接使用。`$CI_JOB_TOKEN` 需要在设置页面先新建一个 Access Token。


GitLab 提供了 [CI Lint](https://gitlab.com/ci/lint) 工具检查 `.gitlab-ci.yml` 文件的语法正确性。

### Dockerfile

CI 的最后一步是 `build` Docker Image，所以要提供 Dockerfile 文件。

```yml
FROM node:8.0

RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN mkdir -p /app
WORKDIR /app

ADD node_modules /app/node_modules
ADD app/*.js /app/app/
ADD config/*.js /app/config/
ADD app.js /app/app.js
ADD package.json /app/package.json

RUN cd /app

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["npm", "start"]
```

值得注意下的是 `ADD` 命令，如果：

1. `ADD` 文件夹到目标位置，目标路径结尾没有 `/`：`ADD node_modules /app/node_modules`
2. `ADD` 多个文件到目标位置，目标路径结尾有 `/`：`ADD app/*.js /app/app/`

## 缺点

目前发现这个过程唯一的缺点是，阿里云从 GitLab `pull image` 的网络连接很差，经常容易失败，比较考验 RP。这是阿里云的老问题了，对 GitHub 和 npm 的连接都很差。

如果对这一点不能忍受，可以选择其他 Docker 仓库，只需修改 `.gitlab-ci.yml` 的最后一句即可。

---

[Configuration of your jobs with .gitlab-ci.yml]: https://docs.gitlab.com/ce/ci/yaml/README.html

[^1]: Configuration of your jobs with .gitlab-ci.yml

