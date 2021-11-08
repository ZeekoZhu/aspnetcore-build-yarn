FROM zeekozhu/aspnetcore-node-deps:6.0.0

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.0 \
    DOTNET_VERSION=6.0.0

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='1b6b5346426e53afd7ea4344e79b29a903b36bb1dfbc88d68f3a17a88b42ca9563d8af7c086cc0d455cb344c7d11896d585667c76e424b2e2760e7421018c1c7' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='7273e40bc301923052e2176e8321462790e3b654688f473dc7cac613ad27f181190dabbba79929f983424c9b5b5085b8d4be9cc9f0f1d0197f58ef3bb9aa8638' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
