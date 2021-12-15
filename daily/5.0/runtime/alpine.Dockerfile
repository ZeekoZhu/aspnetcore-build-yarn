FROM zeekozhu/aspnetcore-node-deps:5.0.13

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.13 \
    DOTNET_VERSION=5.0.13

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='86132e578da8f4a964ce10e9cf63e3acc982bdd3822d89225a938b915c441992e023803547f8bb852c70ea61b7a76e65733f64ae3e171bdd290d73f2705a0b71' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='0ea8a945bb1b663b8bf65708d6cfd6411aaf6ac8cc2ade34dfda160c331230694620b8b0abf80c4266fc9a2444300bf9b58906e40c30e7aff7a27291240ca583' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
