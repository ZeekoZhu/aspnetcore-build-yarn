FROM zeekozhu/aspnetcore-node-deps:3.1.5

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.5 \
    DOTNET_VERSION=3.1.5

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='2f98acecc0779dba03fc5ee674d6305dda780f174af47582d80d556002028df0b6a594e5d13dd36f8a1443e5fc6950ef126064ba6c4b3109b490c6d5ebcb9f39' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='b56aaefdd188106b47f3c20aa65f1fb3b9bdaca450e9599f132c178803119e7611ff8cde07c9248a49923dec1255d1e3e2fb53d7ec5807903c7bd1b1b9954a88' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
