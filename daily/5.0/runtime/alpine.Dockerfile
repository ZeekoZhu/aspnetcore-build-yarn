FROM zeekozhu/aspnetcore-node-deps:5.0.4

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.4 \
    DOTNET_VERSION=5.0.4

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='6354c3b9cd3a7f650282c621bffbbaf435d0d5b02e99ff2e95d0c8680c760eb62319b84def1bcc4459ec4761ffc53dd22ddc98358448d23c1f5028d1ea4bf3a5' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='73f713d64db2c91b21f835a8bacef33894fb636b8d091ceff270ef2aeeb6b3ef276c17936371b533211083990e97130a85ccabf5cc809fd41612299611e3f7b4' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
