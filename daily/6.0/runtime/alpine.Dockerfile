FROM zeekozhu/aspnetcore-node-deps:6.0.0-rc.1.21452.15

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.0-rc.1.21452.15 \
    DOTNET_VERSION=6.0.0-rc.1.21451.13

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='41d6b4f68a7bdef7e91b5a153106f7767afa9a0a76e8e5f724a2a44aaf3d7cb6eba8981fbb2426dd4cb669cbd5f071901d4893b4f22760641c94e2dae9ea74cd' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='c34e939169faafd9ffc2189695f7e5e134170b131850606c781b80801aab3f8b73a6c4bdb0dbe9b104b065e0585339deec97da367662ed0cf1f0e7dcd009cee1' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
