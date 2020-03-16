FROM zeekozhu/aspnetcore-node-deps:{{DepsVersion}}

# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/3.0/aspnet/alpine3.9/amd64/Dockerfile

# Install ASP.NET Core
ENV ASPNETCORE_VERSION {{AspNetCoreVersion}}

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='{{AspNetCoreSHA}}' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
