FROM zeekozhu/aspnetcore-node-deps:6.0.3

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.3 \
    DOTNET_VERSION=6.0.3

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='ad82ce8e1f670188d0d7f384546c88c963aaeccd91f9d0fcb3fe7cf5bfa972b8c9a7a4eaf8e1cdbb8a6ff4257a5f27e7ea4d33e6b0555acb33f8cb791a352290' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='9d334a62e8f591f4cac70b970b20a45d7557a75aa1bccc34891ee4ea9a0ae9d7b046b3dd8ba4a922398198eb7275f9f50177fe8287f2dac7e99a883a448b63d1' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
