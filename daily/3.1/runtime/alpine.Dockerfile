FROM zeekozhu/aspnetcore-node-deps:3.1.15

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.15 \
    DOTNET_VERSION=3.1.15

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='c6686acbd398ca9ff5c47cde4a59f38794b207f2f3bd00d8f2b7e1dea04160f495cdb39f79e663d413d837a131c45bc9ee03653b59734cdacaa2c2fc0a57a002' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='c7c39bf9adbec0389cda30c8f0dd19f57eecfb873288da00fce9d07e6247f16772458b07b46afc9ca79a0f8dc2349d87a79cb77637f13f51824818eb26bb8270' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
