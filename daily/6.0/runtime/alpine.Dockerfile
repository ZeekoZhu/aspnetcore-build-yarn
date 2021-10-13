FROM zeekozhu/aspnetcore-node-deps:6.0.0-rc.2.21480.10

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.0-rc.2.21480.10 \
    DOTNET_VERSION=6.0.0-rc.2.21480.5

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='ee3fb0c0311e0d88ae3f8b0d150f8d98da4fa24d77c429438fad04393b24e214db49bfbc4c9e89918e99061004d63f40ec7b76cb1c0e1c2b12414be29ab63238' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='bb85419cdc2cd6d5f357737230038d3ab685832a48964ef9e8a9f783e1ed6cba0f293ed47e187f05209f3d4c919d81de27c5add5c2424e15bc1b0600c92ed390' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
