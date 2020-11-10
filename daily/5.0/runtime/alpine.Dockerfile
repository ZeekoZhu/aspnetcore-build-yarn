FROM zeekozhu/aspnetcore-node-deps:5.0.0

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.0 \
    DOTNET_VERSION=5.0.0

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='c112bdc4308c0b49fa4f4f9845bf13bfcfe2debed9166e6e6922f389c043d6f7f55a7cc3e03778c08df3ffd415059b90dfb87ce84c95a0fb1de0a6e9f4428b6f' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='1f36800145889f6e8dd823deffce309094d35c646e231fd36fa488c83df76db7b6166eea1d50db0513e0730ca33540cb081f7675ea255135e4e553e7aa5ef2ce' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
