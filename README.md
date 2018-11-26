# aspnetcore-build-yarn

[![Build Status](https://travis-ci.org/ZeekoZhu/aspnetcore-build-yarn.svg?branch=master)](https://travis-ci.org/ZeekoZhu/aspnetcore-build-yarn)

*Based on `microsoft/aspnetcore-build:2.0` and `microsoft/dotnet:2.1-sdk`*

## Tags

### [aspnetcore-build-yarn](https://hub.docker.com/r/zeekozhu/aspnetcore-build-yarn/)

Official `aspnetcore-build` docker image with nodejs and yarn preinstalled.

- `2.0.8`,`2.0` [2.0/Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.0/Dockerfile)
- `2.1.6`, `2.1`, `latest` [2.1/sdk/Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.1/sdk/Dockerfile)
- `2.1.6-alpine`,`2.1-alpine` [2.1/sdk/alpine.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.1/sdk/alpine.Dockerfile)
- `2.1.6-chromium`,`2.1-chromium` [2.1/sdk/chromium.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.1/sdk/alpine.Dockerfile)

### [aspnetcore-node](https://hub.docker.com/r/zeekozhu/aspnetcore-node/)

Official `dotnet:2.1-aspnetcore-runtime` docker image with nodejs preinstalled.

- `2.1`,`2.1.6` [2.1/runtime/Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.1/runtime/Dockerfile)
- `2.1-alpine`,`2.1.6-alpine` [2.1/runtime/alpine.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.1/runtime/alpine.Dockerfile)

## Different from original 2.0.x image

- remove `gulp` and `bower`
- add `yarn@10.12.3`

## Different from original 2.1.x image

- add `nodejs@10.13.0`
- add `yarn@10.12.3`
