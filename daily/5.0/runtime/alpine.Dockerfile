FROM zeekozhu/aspnetcore-node-deps:5.0.2

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.2 \
    DOTNET_VERSION=5.0.2

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='84e69846188689cf5ee1eddce77c6cf92a7becddac9cdd9b985a490446d5acbd5d59e3703e8da4241895c1907b85bac852735c756098774e3b890c1944cda64f' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='d9582bee1dc513288d386ee52bdeb9ed4d5d191d6843b68773f7979ea0d0527c35599722d700a33ce9d59752b44666b17ab7bb36da169c180965252a2742174c' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
