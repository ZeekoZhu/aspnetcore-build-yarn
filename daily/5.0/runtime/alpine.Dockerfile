FROM zeekozhu/aspnetcore-node-deps:5.0.0-preview.7.20365.19

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.0-preview.7.20365.19 \
    DOTNET_VERSION=5.0.0-preview.7.20364.11

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='8b68b7601ceddbc513272b3c80ba2439046b397e96ffaa07b24efcc5bb32c7854f5a4f851c4f08cc9201167d07f17427e750a51d7392cf2eb9f6e4d0fbbb41b7' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='ff63042916c597820fa93eac34a6c0d889b9498aae554067010a94af367b8291f59fcd0832227274bb864209de486ba1cff87967388147b6f9433be1b5ce0953' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
