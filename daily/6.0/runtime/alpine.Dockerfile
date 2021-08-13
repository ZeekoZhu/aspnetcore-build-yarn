FROM zeekozhu/aspnetcore-node-deps:6.0.0-preview.7.21378.6

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.0-preview.7.21378.6 \
    DOTNET_VERSION=6.0.0-preview.7.21377.19

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='060be1fe4d0b7fb5618d5a1f9482767667c96794111188678c5a9004a5961381f0856f57a6cd77f4ea1883a3e523f1f5c35ec6c72fcab67c9aa725ad8e5b0e6b' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='9c26f6ab72569d347eed4772997ce3df5598ed0f2b21f5042f4da321d07ba97e6c1d1b73617ea26ac1d846a96119c5038eecbf3874ac21bb3a2b5f04daeca8a2' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
