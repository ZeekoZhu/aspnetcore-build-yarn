FROM zeekozhu/aspnetcore-node-deps:5.0.7

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.7 \
    DOTNET_VERSION=5.0.7

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='df66e9915146ca018f8d62e118de190d16ee4db65c3373113168cda61632e5a65d39aa4dc76b0f95673d84c089135c8011f7ad0ea3c2a06d4491cfae810c23f6' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='740665d3e4bb1a2c37ca2de9b6a91e2fdb83192927095678d57c3978892658f8401df56591795088d47dc1148b150aa9389277502b1dfc66e71479b16e0c7cd2' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
