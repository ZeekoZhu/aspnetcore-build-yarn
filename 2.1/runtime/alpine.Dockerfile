FROM zeekozhu/aspnetcore-node-deps:2.1.4

# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/2.1/aspnetcore-runtime/alpine3.7/amd64/Dockerfile

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 2.1.4

RUN apk add --no-cache --virtual .build-deps \
    openssl \
    && curl --output aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='88309e5ddc1527f8ad19418bc1a628ed36fa5b21318a51252590ffa861e97bd4f628731bdde6cd481a1519d508c94960310e403b6cdc0e94c1781b405952ea3a' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && apk del .build-deps
