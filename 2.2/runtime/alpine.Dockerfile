FROM zeekozhu/aspnetcore-node-deps:2.2.1

# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/2.2/aspnetcore-runtime/alpine3.8/amd64/Dockerfile

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 2.2.2

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='2cfa356d99b39240faf65f6307ef558625ad78cc49ffcddefb0dff5e7a4d3ee318574b47d3ff6b8981d13e05222d81c717900550553976aed287a0f66d032712' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
