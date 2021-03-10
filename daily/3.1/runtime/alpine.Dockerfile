FROM zeekozhu/aspnetcore-node-deps:3.1.13

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.13 \
    DOTNET_VERSION=3.1.13

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='40f23e81ca8fa8bcb657e480a475650b2e3c59daad702e2cce0ee8daba18e9703f03bb02a28bd9ae548410b0f503ebdaa6de1079b417798f965217fc0ee94cd0' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='418b18bfd3a5e03ba0129720eef361fae6ba001263a0ec72b4cc018b8a6b90c8215df1ffae26c429e5a594c4425275996454666e6e0f2d66efffa6c844ee1a1a' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
