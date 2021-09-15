FROM zeekozhu/aspnetcore-node-deps:3.1.19

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.19 \
    DOTNET_VERSION=3.1.19

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='dcee0837238f292b127b123cf774c7544f3fa2f509114b141198f84ac06fdb3a9d91af6d5829b16866bf654dbcf829de61b13d16677af67318795e2d93dbff7d' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='f90e83939d947e45d1f50647a77b90cfc8f91fe4295921736b4a57130d92434e463ae28885a1fb1b6455bdfeb478a665c5f5bc4e943c27a1eff08f1da2a4dec2' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
