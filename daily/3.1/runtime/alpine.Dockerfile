FROM zeekozhu/aspnetcore-node-deps:3.1.0

# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/3.0/aspnet/alpine3.9/amd64/Dockerfile

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 3.1.0

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='fa5e4ae71134a8a6db4ad6a247d3e31406673e03f0a64f7faaad3d84cfb3b70d2cf69e9d9abc1f8688138907d4ddd37cd908669999d85a87892e164053c63847' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
