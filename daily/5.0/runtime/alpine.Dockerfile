FROM zeekozhu/aspnetcore-node-deps:5.0.11

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.11 \
    DOTNET_VERSION=5.0.11

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='86a149621e26a67ec72e8c7c11f8361d20a3a9043e5b66d8048317a43d8de834930fa4b6cf32804adbfb8a3c36875b8f69e0331a4133dc48ab3ac1c6409f2266' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='0df3cd63230702520bc5678c4e7c7baed27a0525ead160d9bee509d7c42d0d2fa5cab79bf527727a6d9deb464953522e8b3d5de4a37b52ff9ac678dfdff2789a' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
