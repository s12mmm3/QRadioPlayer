# QRadioPlayer

基于Qt实现的 网易云音乐 广播电台客户端

[![GitHub Actions CI Status](https://github.com/s12mmm3/QRadioPlayer/actions/workflows/windows.yml/badge.svg)](https://github.com/s12mmm3/QRadioPlayer/actions/workflows/windows.yml)

![C++ version](https://img.shields.io/badge/C++-11-00599C?logo=++)
[![Qt version](https://img.shields.io/badge/Qt-6.9+-41CD52?logo=qt)](https://www.qt.io)
![GitHub license](https://img.shields.io/github/license/s12mmm3/QRadioPlayer)

## 简介

基于Qt实现的 网易云音乐 广播电台客户端

支持跨平台和多种编译器编译，基于[Qt版 网易云音乐 API](https://github.com/s12mmm3/QCloudMusicApi)实现

### 目录

- [需求和依赖](#需求和依赖)
- [编译方式](#编译方式)
- [License](#License)

---

## 需求和依赖

- [Qt 6.9+](https://www.qt.io/download-qt-installer)

## 编译方式

```Shell
git clone --recursive https://github.com/s12mmm3/QRadioPlayer.git
cd QRadioPlayer
cmake -B build
cmake --build build -j
```

## License

[The MIT License (MIT)](https://github.com/s12mmm3/QRadioPlayer/blob/master/LICENSE)