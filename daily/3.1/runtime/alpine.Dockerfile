FROM zeekozhu/aspnetcore-node-deps:3.1.22

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.22 \
    DOTNET_VERSION=3.1.22

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='708d17a4f3fc0bb866343f359e88543c99c70511d1d90fa3c889ce126bd2625f2ce3118552dbea52b3410b70586ad5f551453de41c6cb88ec77e131854979955' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='36fd0f7d1922f3da4eb5b6624a4c58aee01c7a74c9727e27f1efcb39459ca9cf9cbcbdbb8253ae9bb713f84448622dc2e8d7e1a7bf6b86cf602be41aa325feb4' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
