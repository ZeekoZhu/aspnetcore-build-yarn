FROM zeekozhu/aspnetcore-node-deps:5.0.5

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.5 \
    DOTNET_VERSION=5.0.5

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='c0910f24938cc0dcf2f9f8277962eaf568b2be07c31ce5f3f2c1306c50012ed46fde1be3535f7ac7f5a3f63219a573c9ebbc4b7a2e869fcc435b14f0b79c0b13' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='04057353d890e73f5fe93cf9d05b2e84bf1f972a401acc631fc7ee7b83e97a4e40343458f274b7e900f96b94fbd2b954bde89b8874367776c82cb17567091d23' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
