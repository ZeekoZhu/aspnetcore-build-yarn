FROM zeekozhu/aspnetcore-node-deps:3.0.0-preview6.19307.2

# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/3.0/aspnet/alpine3.9/amd64/Dockerfile

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 3.0.0-preview6.19307.2

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='3c015b35995dacc514f7b3637a033e8ed0310a1ce9771a255eac215993bf386f6eeb43bccb5decb883041cf83bf6229c6aa271d5d26c63e95e1322b241d0bac9' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
