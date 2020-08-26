FROM zeekozhu/aspnetcore-node-deps:5.0.0-preview.8.20414.8

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.0-preview.8.20414.8 \
    DOTNET_VERSION=5.0.0-preview.8.20407.11

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='fa301f0809a44f2ba6119ac2e39798ad004ed30bf92d1996ea848f50bf06fc9a18d53eaaf907c89690c763b8ab31cb300ff9bfc6dbf2fe115f77467ef788eb35' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='d1d4538373b353063cf3f7eaaea6a5aaada6c0b0fd20bbfdc34c38d0a1d0f4b5dabf559ec2add86aa4617122ec46fbdf8833b1b4e1de8df521b1d77dd484545e' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
