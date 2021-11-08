FROM zeekozhu/aspnetcore-node-deps:5.0.12

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.12 \
    DOTNET_VERSION=5.0.12

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='ce33b8b5ccb35ac636e37777a084881bf66ba67c32febc06c4829e37f86512eece0e6a689ce3184e0a70b23e0cf43110facfa39931a13e9e44899c1c5e296fe5' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='f5f58aee8d497e39b931354357c14c654acf2025c71435273d1d3c086410366352c6814c39ce7d5752ae0bbf293d99fa351c30a56b95ebeb82dcc8eb5269f2bb' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
