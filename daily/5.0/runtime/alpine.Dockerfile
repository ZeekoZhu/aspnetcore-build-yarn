FROM zeekozhu/aspnetcore-node-deps:5.0.15

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.15 \
    DOTNET_VERSION=5.0.15

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='9ac891ea130e0cc6a718adf0c4f1e3da327e2fe8c69d7df9625ebbf6f91c6351a20e669ff47bb527c057d4a91a29c818c183ab026a0b50fa94d148b25d7065f1' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='efb8489cd56e8ea4b5a8c844193f68986dd5438c567157481b2fd6489540f3d67daab6656b335a72fea3220feb1d81009167db08ccd615c1c203a698019acebd' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
