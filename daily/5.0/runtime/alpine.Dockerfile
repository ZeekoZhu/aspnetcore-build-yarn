FROM zeekozhu/aspnetcore-node-deps:5.0.8

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.8 \
    DOTNET_VERSION=5.0.8

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='3763a6eb74c176dde843eeeebc37050dec8beaaa2e0d2205a9e010c6cdb1ed57bf0b44b6667badea5f9bee763c3fbd13904cdc4d4b156754fe488aef0502ad34' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='ea4d787e68fb4ab61448aa26894696192329d4e3a98ba9c95da588ec299523cca2d3b0a4e6ea35354b11cfd4ce9da594969806beb34cee249aac76dab46eb295' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
