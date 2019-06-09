# aspnetcore-build-yarn

[![Build Status](https://travis-ci.org/ZeekoZhu/aspnetcore-build-yarn.svg)](https://travis-ci.org/ZeekoZhu/aspnetcore-build-yarn)

## Tags

### [aspnetcore-build-yarn](https://hub.docker.com/r/zeekozhu/aspnetcore-build-yarn/)

Official dotnet-sdk docker image with nodejs and yarn preinstalled.

- `2.2.300-alpine`,`2.2-alpine` [3.0/runtime/alpine.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/3.0/sdk/alpine.Dockerfile)
- `2.2.300-chromium`,`2.2-chromium` [2.2/sdk/chromium.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.2/sdk/alpine.Dockerfile)
- *Preview* `3.0.100-chromium`,`3.0-chromium` [3.0/sdk/chromium.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/3.0/sdk/alpine.Dockerfile)
- *Preview* `3.0-alpine`,`3.0.100-alpine` [3.0/runtime/alpine.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/3.0/sdk/alpine.Dockerfile)

### [aspnetcore-node](https://hub.docker.com/r/zeekozhu/aspnetcore-node/)

Official aspnetcore runtime docker image with nodejs preinstalled.

- `2.2-alpine`,`2.2.5-alpine` [2.2/runtime/alpine.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.2/runtime/alpine.Dockerfile)
- *Preview* `3.0-alpine`,`3.0.0-alpine` [3.0/runtime/alpine.Dockerfile](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/3.0/runtime/alpine.Dockerfile)

## Different from original 2.2 image

- add `yarn@1.16.0`
- add `nodejs@12.3.1`

## Different from original 2.1.x image

- add `yarn@1.16.0`
- add `nodejs@12.4.0`

More details can be found in specifications:

- [2.2.spec.toml](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/2.2.spec.toml)
- [3.0.spec.toml](https://github.com/ZeekoZhu/aspnetcore-build-yarn/blob/master/3.0.spec.toml)

## Notes

In 3.0 preview images, it is not confirmed that chromnium(=73.0.3683.75-1) will work with latest selenium
