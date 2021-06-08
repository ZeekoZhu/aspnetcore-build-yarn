FROM zeekozhu/aspnetcore-node-deps:3.1.16

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.16 \
    DOTNET_VERSION=3.1.16

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='74cbf5617c9c5d6a0d371db3fe2af10b89d7f0328c9e0db40015b0ed1d2092126b7f831134fb0a7c8557627f6d6597de886e885e8b8c4f5c6a9e109b5fcdb92e' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='0357a441f085cd91d61cefe02b3933a77fbac9dc2b0b4b7dec4dccf13220ce7b25152f2f17d6d6a14fd3762cac40f0a6cdcf5d56dd44b4724762ea2caeba6c87' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
