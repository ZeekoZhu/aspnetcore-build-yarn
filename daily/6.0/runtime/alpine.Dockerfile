FROM zeekozhu/aspnetcore-node-deps:6.0.1

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.1 \
    DOTNET_VERSION=6.0.1

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='bcb328eb00ad53ae2f8ebce8802dda1329de68cbba120311d69a5f235f81ee59316728289f7797f23f657102d50751e3cff641538d4670ac8fd85da1d57feb97' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='763a9895e20ac19012b6fb6489be45a25879c3717e47b7c8f13e38e5c8a33e9ccdf5fe0a90896bd4719324cc24397c62f06426e9dd43c9cdf42296fcb08a1f26' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
