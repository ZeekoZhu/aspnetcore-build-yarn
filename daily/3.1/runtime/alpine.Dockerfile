FROM zeekozhu/aspnetcore-node-deps:3.1.11

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.11 \
    DOTNET_VERSION=3.1.11

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='d8e8e30e0b9cd619d11dac5d7466f39fa5ad099dfda0e1b4d8c06e4e4e33bcab81456eda2f83db47ed19469b4c1208b544df254316a95b1244e09b4d62e2e8bb' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='dfe6c191cbd87cf926a85da59095171df13c8bef8a5a8b7089c986475c4f3c508c66302ec008bee9ef458c2b2a5f9c348371139a2cddc3d9e0d74e879bc0f31a' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
