FROM zeekozhu/aspnetcore-node-deps:6.0.0-preview.6.21355.2

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.0-preview.6.21355.2 \
    DOTNET_VERSION=6.0.0-preview.6.21352.12

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='ccd1da6558a1d54e5ad4b651684990d56b7516c5968371f04a9d8f59c847073270ff916b185a1cbd93ddb362ff44e358db1be0335af12bbae0aa22db845057d4' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='4c5c327e431903d05524b4cbb506a6b4fa18f342caf0fb3ce28068fae86c1428c8ae6ef324a7885031d33f91009b5e6eed48b3352ece1351a86c08b42d5d0702' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
