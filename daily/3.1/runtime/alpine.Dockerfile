FROM zeekozhu/aspnetcore-node-deps:3.1.14

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.14 \
    DOTNET_VERSION=3.1.14

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='77856f6183ef7ee561fe8510e89148566972ae21e3915242ae4ac7ef987b1aa78cda09bb06fdae96cd03758975dc5eb0e8652dea79b96db327ac5de2a4d41961' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='bcdd66e48af4703764588e0b76ec1997f1a391d6e840a675af0155669f16c874d9b66b4906c25b717c6955ae2032d064b32e283205519f61d1b4b673db2b3421' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
