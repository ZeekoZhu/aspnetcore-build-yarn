FROM zeekozhu/aspnetcore-node-deps:3.1.2

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.2 \
    DOTNET_VERSION=3.1.2

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='d0cf4ec3f7068fbd300c99715ca40cd6bde5566c5c0104437084a97a35e3a2c200d2c413ad1bb7e3b8f8433ac079b81793e750f7fbdc548c5841bca99742f8b2' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='7a171932a99c10e003deb39cd2377fe8ef4486d75da372ca0aecefbd3c065816320573c9384fd3ceac1793acf06079a802999e479f3dff816651c043ed05a245' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
