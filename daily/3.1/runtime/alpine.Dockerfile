FROM zeekozhu/aspnetcore-node-deps:3.1.7

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.7 \
    DOTNET_VERSION=3.1.7

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='b982c3f397f40a79b2bbe852083b648dc0c2ee530307127a1b6f5020d32322bd9eecaab9440d729dcaa5c1ce408bf37450411f5a0d83061b2ddc84e4dc043d3c' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='43df2fa8660a9dff03cf8412ad7a78f9e790be0cbcabc69c4ab69c640a3efbe3327cd2f98101dd6adf8a8a51e2692a2404358c2a3457321098dc815cc87c55dc' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
