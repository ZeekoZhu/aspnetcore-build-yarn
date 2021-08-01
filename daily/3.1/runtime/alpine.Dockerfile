FROM zeekozhu/aspnetcore-node-deps:3.1.17

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.17 \
    DOTNET_VERSION=3.1.17

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='aca9ff3a2d3105eed366816fedee8fa0d3c06f0c1081a9df5ad6e7638e540299d4452faefd42518de2023fccb4169127883c0f30f202b3b1a6ac9a68aa9e9efd' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='8861552d21a7efed982f31d228d42da7f8de8cb5343771de96034b3ddcabca2f9bc96bdadc40c7732c217bbc1b4d68999e91a98541076d6b5f535c2e6c9f8a4f' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
