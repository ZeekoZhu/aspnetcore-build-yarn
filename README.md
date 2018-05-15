# aspnetcore-build-yarn

![travis-ci](https://api.travis-ci.org/ZeekoZhu/aspnetcore-build-yarn.svg?branch=master)

*Based on `microsoft/aspnetcore-build:2.0` and `microsoft/dotnet:2.1-sdk`*

## Tags

### aspnetcore-build

Official `aspnetcore-build` docker image with nodejs, yarn and webpack preinstalled.

- `2.0.8`.`2.0`,`latest` [2.0/Dockerfile](2.0/Dockerfile)
- `2.1.0-rc1`,`2.1` [2.1/sdk/Dockerfile](2.1/sdk/Dockerfile)

### aspnetcore-node

Official `dotnet:2.1-aspnetcore-runtime` docker image with nodejs and webpack preinstalled.

- `2.1`,`2.1.0-rc1` [2.1/runtime/Dockerfile](2.1/runtime/Dockerfile)

## Different from original 2.0.x image

- remove `gulp` and `bower`
- add `yarn-1.5.1`
- add `webpack@4`
- add `webpack-cli@2`

## Different from original 2.1.x image

- add `nodejs@8.11.1`
- add `yarn-1.5.1`
- add `webpack@4`
- add `webpack-cli@2`
