FROM zeekozhu/aspnetcore-node-deps:3.1.6

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.6 \
    DOTNET_VERSION=3.1.6

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='373643ccec92752468978e312f86725718c650a0bc83d8ea3faeb09d0ccb230c0c4626d6c5cb10481cf269687b01070b6fa874276963923872a6af748d2617bc' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='fc0b6acc3031673a0f77b53a028c86c1dd55da08d4c45792d46fd040792cc5668cba3e0b29c5642897df04e66a095eff66d0eee4b92b04bdabeea2442c264166' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
