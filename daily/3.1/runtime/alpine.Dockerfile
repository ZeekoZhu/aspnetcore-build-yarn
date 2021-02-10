FROM zeekozhu/aspnetcore-node-deps:3.1.12

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.12 \
    DOTNET_VERSION=3.1.12

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='f38aced794bba9a896df969667b2b01528f7857b2dd9b9018c4c2c8e1e646c6ed44e66b9b28f76bded1472fb0dd932a575c6887c5a0da9848bb3d2694751a413' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='0e4ef3c8884c3ebf5db99733e89edaf8c1272bae8ad2f88dab708e8566020d161960cd4f6f4d0df7231da36ab6248670a50c3dd415d740ac8d26e86dd69e2438' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
