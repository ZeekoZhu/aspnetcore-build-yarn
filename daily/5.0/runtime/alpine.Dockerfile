FROM zeekozhu/aspnetcore-node-deps:5.0.9

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.9 \
    DOTNET_VERSION=5.0.9

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='0b6e7ada8b07e09d2bbf2cae0d8667c0a0876e3d77876958dae3f95e2c98e74c078c663a1fdb326f9bc46abc3c2d86c518cce4a170ad1128e3f20702410eabca' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='a143033b6dcc3de5f4ca44fa0f64bd72b93ae09184fb773d6e8d809fecd495b64040a15d9888f1209dab825adf21e76a741271ba16dd84312ca0640ae3683085' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
