FROM zeekozhu/aspnetcore-node-deps:2.2.5


# Copy and paste from https://github.com/dotnet/dotnet-docker/blob/master/2.2/sdk/alpine3.8/amd64/Dockerfile
# Disable the invariant mode (set in base image)
RUN apk add --no-cache icu-libs

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

ENV DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    FAKE_DETAILED_ERRORS=true \
    PATH="/root/.dotnet/tools:${PATH}"

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.2.300

RUN wget -O dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='5e58b1d404ce26036dfc8feea57086df76d47228fb7e023c1ed1db2c0360693780e86b3bd87f5b0a667476c8c3fe0bd6ddb5be3a06dff0cfeaa86ae5d4423c7d' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

# Enable correct mode for dotnet watch (only mode supported in a container)
ENV DOTNET_USE_POLLING_FILE_WATCHER=true \ 
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help

WORKDIR /
