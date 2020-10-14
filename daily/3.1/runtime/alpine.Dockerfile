FROM zeekozhu/aspnetcore-node-deps:3.1.9

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=3.1.9 \
    DOTNET_VERSION=3.1.9

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='98778ec5ead5008b018e03defbe6eafe5d7a61e81689ae072dfff2135698e4bf4053d72a81851a25129d5969e3dca1258360961318db44adc3c94a7fd5cd2892' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='016dcf06ee019a3358c0431187a28cb184c352f14e3615e8d8cc5e47450ce964a33217f80b42eae0d90c9e6e3628585314a68fcae2ba191f49e258bb27a22907' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
