FROM zeekozhu/aspnetcore-node-deps:3.1.18

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.18 \
    DOTNET_VERSION=3.1.18

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='1863a63652f9530ca26c82d715906023be6e2a67e6c7b50368f006e0b115b724f8a50298c3084dfeb14e4e4db9d52eab30086ede210f938b395de2ac7d69d046' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='6288002d8281594d6b928f887b7a24c221acc52d584155fada7198e0cb53c77357867df6e23331b71bc7c3150ed71632e16503b0639ad5c72acf59959fcf6cb3' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
