FROM zeekozhu/aspnetcore-node-deps:5.0.0-rc.2.20475.17

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.0-rc.2.20475.17 \
    DOTNET_VERSION=5.0.0-rc.2.20475.5

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='2e4baec3c3746210cae4e920046ec6bede9caed1cdf30382295fd1b203bf08e6bee5bee0da3067f0317b31d5d836b6ce63b63fd163d599e71d71fc30f0ef37f1' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='35e85d3e822317a96dbba0aa239fe05e4f85e77031e3ba0c1fbd2a0800898bdaf377b800ab2a02510d2c0e0e6c51da1659b5afa919ebd0540fea2e02a8d7fa92' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
