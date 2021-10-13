FROM zeekozhu/aspnetcore-node-deps:3.1.20

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.20 \
    DOTNET_VERSION=3.1.20

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='6965afa8d5639edb293f44b8da3f42a0fec8a7c1673174da93963fab8a6bc3521a8e921e69b40a6b73c25ce25264a9be3b88205f2a7fa2c7a2ea8986f2227113' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='e910816ccf840f2eed8546ed441acc968baff241522cf5c6456f38cd3344fc13eaf15d5a8daa5b4422ed63e79b8434b2a3413d7c660ecbdab437efdf88507b0c' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
