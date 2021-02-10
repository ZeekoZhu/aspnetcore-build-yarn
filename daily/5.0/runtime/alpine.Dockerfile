FROM zeekozhu/aspnetcore-node-deps:5.0.3

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.3 \
    DOTNET_VERSION=5.0.3

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='85e4063792fb9d921a24f9da221a2b69c1faa253adb10644cc5907c35af92b3204f461fd6a9ec936ae37cfada47937f1c2b67174eabc778bd7305d66dc67e340' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='cd4471a542b4883987c067ecf180bd1ccc414f54fc90dd134c59bdba58f8e102366494b4fffb242de57c248d3915f34953de5330a9664b318ae58c1e1c004905' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
