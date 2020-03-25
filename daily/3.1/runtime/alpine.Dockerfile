FROM zeekozhu/aspnetcore-node-deps:3.1.3

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.3 \
    DOTNET_VERSION=3.1.3

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='ce8bef0f11c552d18727d39ae5c8751cba8de70b0bb1958afa6a7f2cf7c4c1bff94a7e216c48c3c3f72f756bfcf8d5c9e5d07f90cf91263a68c5914658ae6767' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='918bf1f2cd216d4bf337eb0e528d05c56c71e75f5452d8ad08f1ae53c9434a570f7608392872f1a2a55486b00b4d59216a5f7c081f332c707baba0c86e54efd9' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
