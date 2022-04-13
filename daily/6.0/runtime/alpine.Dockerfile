FROM zeekozhu/aspnetcore-node-deps:6.0.4

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.4 \
    DOTNET_VERSION=6.0.4

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='e5b538482f10a667bee3b7482db0ac0cac27b5bddab9f3ab68bd5c5d7c18c5bec2bdcb8cd288052c3f3e186291ee02190ff01896c2835ce32b87e18cd817759e' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='f54624306b74d9be0a670c2b1d465991b2c1ef67a4c216532fba9dc85f525a68d9ba6e1405945905dc834e073e676f0234d18edc5c9507d5b6c420bb2d073a40' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
