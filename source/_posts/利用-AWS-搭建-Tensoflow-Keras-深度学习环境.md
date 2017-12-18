---
title: 利用 AWS 搭建 Tensoflow + Keras 深度学习环境
date: 2017-12-18 21:31:35
description: 利用 AWS 快速搭建完整的深度学习环境，以极低成本享受 GPU 计算的快感。本文使用 Ubuntu 16.04、Python 3.5、Tensorflow 1.4、Keras 2.1、CUDA 8，cuDNN 6 环境。
tags:
  - DeepLearning
  - Ubuntu
  - Python
  - AWS
  - Tensorflow
  - Keras
  
---

Amazon Web Services（AWS）非常适合用来学习深度学习。其最便宜的 GPU 计算实例 p2.xlarge 基本价格仅 0.9 美元/小时，如果使用竞价（Spot）实例则价格还有可能更低。在你决定出手 1080 Ti 之前，不妨先用 AWS 来练习。

在 AWS 上搭建一个深度学习环境非常简单，但对没有经验的新手来说还是存在一些小坑的。本文记录了我搭建环境的过程。我的环境是 Ubuntu 16.04、Python 3.5、Tensorflow 1.4、Keras 2.1、CUDA 8、cuDNN 6 以及 Jupyter Notebook。

## 启动 AWS 实例

> AWS 地址：https://aws.amazon.com

AWS 提供了大量的产品，我们需要的是 Amazon EC2，即「虚拟服务器」。在开始搭建环境前需要先启动一个「实例」。可以简单地将「实例」理解为服务器。启动一个实例即为「购买」一台服务器。

AWS 后台可以使用美亚账号登录，如果没有就注册一个吧。登录后台后，进入 EC2 服务控制面板。此时先注意一下页面右上角，在你的 ID 右边应该显示当前服务的区域，建议选择亚太的「东京」区域。我在北京联通光纤宽带的环境下实测，东京线路的速度很不错。

> AWS 提供了多个区域供选择，包括美国、亚太、欧洲等。不同地区的实例和 AMI（映像）互不相通，大陆用户建议首选「亚太区域（东京）」。

选好地区后即可「启动实例」。首先需要选择 AMI。因为我们要自己搭建环境，所以这里选择「快速启动」中的「Ubuntu Server 16.04 LTS (HVM), SSD Volume Type」。

> 你也可以在「社区 AMI」中搜索「ami-ef0a8489」，直接使用我已经装好环境的 AMI，则本文到此为止。

创建实例过程中注意三点：

1. 选择「p2.xlarge」实例。p2.xlarge 拥有一块 Nvidia Tesla K80 显卡，应付一般的 DL 的学习，包括参加 Kaggle 的竞赛都够了；
2. AWS 会要求你创建一个 SSH Key，起个简单的名字即可。将下载的 `.pem` 文件放在 `~/.ssh` 目录下，这是你的登录凭证；
3. 注意「安全组」。默认的安全组是禁止一切访问的，将「入站规则」的「来源」设为「任何位置」，否则可能无法登录（如果你知道自己在做什么，则请随意设置）。

等待实例启动后，使用 SSH 登录服务器：

```bash
$ ssh -i ~/.ssh/<filename>.pem ubuntu@<公有 IP>
```

### 收费

p2.xlarge 的基础费用是 0.9 美元/小时，启动即开始计费，停机则停止计费。因此如果你每次使用时间不长，使用完毕记得「停止」即可，费用很低。

如果你需要长期使用（比如需要训练一个大模型），也可以考虑使用「竞价请求」，有机会进一步降低价格。关于竞价请求的介绍可以看这里：https://aws.amazon.com/ec2/spot/

## 安装显卡驱动

### 下载

使用基础 AMI 启动的实例安装了 Ubuntu 16.4 系统和 Python 3.5。第一步需要安装显卡驱动。

下载地址：http://www.nvidia.com/download/driverResults.aspx/122825/en-us

下载好驱动后将文件上传到服务器：

```bash
$ scp -i ~/.ssh/<filename>.pem ~/downloads/<driver>.deb ubuntu@<IP>:~
```

这个命令将 `<driver>.deb` 文件上传到服务器的 `~` 目录（在上一步登录服务器后，你应该已经在这个目录中了）。

### 安装

```bash
sudo apt install ./<driver>.deb
```

等待安装完毕即可。

### 验证安装

安装完成后，运行 `nvidia-smi` 命令，看到显卡信息则说明安装成功。

## 安装 CUDA 8

目前最新的 CUDA 是 9.0，但 Tensorflow 仍然使用 CUDA 8，所以**一定要安装 CUDA 8**，否则使用 Tensorflow 时会报错。

### 下载

下载地址：https://developer.nvidia.com/cuda-80-ga2-download-archive

在这个页面，依次选择「Linux」，「x86_64」，「Ubuntu」，「16.04」，「deb (network)」。将下载得到的文件上传到服务器：

```bash
$ scp -i ~/.ssh/<filename>.pem ~/downloads/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb.deb ubuntu@<IP>:~
```

### 安装

```bash
sudo apt install ./cuda-repo-ubuntu1604_8.0.61-1_amd64.deb.deb
```

### 验证安装

安装完成后应该会看到 `/usr/local/cuda-8.0` 目录。

## 安装 cuDNN

cuDNN 也有一个小坑：其最新版本是 7，但**一定要安装 cuDNN 6**，否则会报错。

### 下载

下载 cuDNN 需要注册 Nvidia Developer 账号并登录。在下载页（https://developer.nvidia.com/rdp/cudnn-download）勾选「I Agree……」即可看到下载列表，谨记选择「Download cuDNN v6.0 (April 27, 2017), for CUDA 8.0」，有三个文件：

1. `cuDNN v6.0 Runtime Library for Ubuntu16.04 (Deb)`
2. `cuDNN v6.0 Developer Library for Ubuntu16.04 (Deb)`
3. `cuDNN v6.0 Code Samples and User Guide for Ubuntu16.04 (Deb)`

依次下载并上传即可。

### 安装

使用同样的命令依次安装三个文件。

### 验证安装

```bash
$ sudo find / -name libcudnn*
```

可以看到一系列 `libcudnn6` 的相关文件。

## 安装 Tensorflow

默认环境安装了 Python 3.5 但是没有安装 `pip3`，所以我们先安装它：

```bash
$ sudo apt-get install python3-pip python3-dev
```

然后安装 Tensorflow：

```bash
$ sudo pip3 install tensorflow-gpu
```

### 验证安装

```bash
$ python3
>>> import tensorflow
```

通常这里如果没有报错，就说明 Tensorflow 已经正确安装了。

> 参考资料：[Installing TensorFlow on Ubuntu](https://www.tensorflow.org/install/install_linux#InstallingNativePip)

## 安装 Keras

安装 Keras 比较简单，直接 `pip3` 安装即可：

```bash
$ sudo pip3 install keras
$ sudo pip3 install jupyter notebook
```

## 安装 Jupyter Notebook

Jupyter 官方建议使用 Anaconda，这也是我们通常推荐使用环境。不过因为我们使用 AWS 通常只是针对特定的项目，而且是临时性使用，可以把整个实例看作一个隔离的环境，所以就不使用 Anaconda 而直接安装了：

```bash
python3 -m pip install jupyter
```

## 开始项目

现在我们已经安装好了基本环境，你可以继续根据需要安装其他包，例如 `numpy`、`pandas` 等。要开始项目，只需要启动 Jupyter Notebook 即可：

```bash
$ jupyter notebook --ip=0.0.0.0
```

然后就可以在本地浏览器打开 `<IP>:8888` 访问服务器上的 notebook，开始愉快地开发了。不过通常建议先在本地开发，确定程序没问题后，再到服务器上进行训练，毕竟服务器是按时间收费。

**参考资料**

[Installing TensorFlow on Ubuntu](https://www.tensorflow.org/install/install_linux#InstallingNativePip)

[Keras Documentation#Installation](https://keras.io/#installation)

[Installing Jupyter](http://jupyter.org/install.html)