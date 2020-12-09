FROM zeekozhu/aspnetcore-node-deps:5.0.1

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.1 \
    DOTNET_VERSION=5.0.1

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='9a6eef8077f2d1a25a1b4ee9dd9300ac6ddd51b59ce14dd80e105cb18c27f8337517548595b8081be959d4c4d40339997931ed14b4d43aeca8d335c58bc382de' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='004fe94ba94b23eadd91ac2a95d175ee41b5550cdda9c5f48b0c090848562e1b5a33c9875517e9ff4d3c3a18b7c6f2c74d14c0860d3f4c68d388939412a72452' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
