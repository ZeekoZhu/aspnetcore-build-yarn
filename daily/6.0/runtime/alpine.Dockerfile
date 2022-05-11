FROM zeekozhu/aspnetcore-node-deps:6.0.5

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.5 \
    DOTNET_VERSION=6.0.5

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='de0224c5cb933ff557d19c4293a7a3591a54ae1b5d2de1f663195a1cab34c89986999fd63d43fe6d31fc5ad467d5f5cbd15636fa672c34303fc7eddb1708db7f' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='b9f07997e5a930e096772a182fcb8f44826cf5fdaf4a5f8d5a9eba4f157373c694a50f57ee1b799fb0e6d4c4d8389cb45409d928e3fc5ea6f56303a190e1941a' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
