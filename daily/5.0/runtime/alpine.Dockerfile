FROM zeekozhu/aspnetcore-node-deps:5.0.10

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.10 \
    DOTNET_VERSION=5.0.10

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='d0ca3aef030a575daf09fcfb8abc3056dcb6567da661c8c18162882a8ae9af3de013053ada82e0ee3042a806cb10dd234f59aa5bbdcd229d5ead582464ad4154' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='0e995f892eca8893e211e9965b2378da263233ad92c5f32624c4dfbdaec1ad7b8b3c5496a27a81891b321eb12d7a08445cd86832e219584a31cad4baef18b9d2' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
