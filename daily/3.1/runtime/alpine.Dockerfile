FROM zeekozhu/aspnetcore-node-deps:3.1.21

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.21 \
    DOTNET_VERSION=3.1.21

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='73e7fb6f7ddd4e6e7891fd006d18c4cfb07120dd4fd15458b01656540c77df667704d3c9068dea1177ea37fccbefd7bcec0c7d2e58660859e7ac8bc6cfff07f7' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='aacef811d7d6c549671212da79f9ce85100c9a898ed33091190679ffd83cbc7e984eb582e223f03ce0f4d4300393bc9e65d29824143175ac78a9cbfdb2a46aeb' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
