FROM zeekozhu/aspnetcore-node-deps:3.1.8

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.8 \
    DOTNET_VERSION=3.1.8

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='6b441b3d658026af0c4ba3d852f4cde5c3a6336c01f0bfb244b1a2619becb44730c2bdb2c0a86b9ef3767660c776e44ce72b9a0e0bcf428b1e9d82c8a7d96267' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='e1ca4d3e7b8e5f549d7b62b1d56b191c04f2909b8965565561174cc0d54622aec45b07f115560c87615bb0d96b32980ca593fbfaf3d28359d61f0f6245c7d218' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
