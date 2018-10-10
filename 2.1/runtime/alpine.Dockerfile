FROM zeekozhu/aspnetcore-node-deps:2.1.5

# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/2.1/aspnetcore-runtime/alpine3.7/amd64/Dockerfile

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 2.1.5

RUN apk add --no-cache --virtual .build-deps \
    openssl \
    && curl --output aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='5d87fb86e4e70bf0769d081a0b0c4388348bcefe61559242af17a9604bbdb3269e4ab47c420105ab6a2236431978adede9406d3ff0845602a398bb81f4ecf6f7' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && apk del .build-deps
