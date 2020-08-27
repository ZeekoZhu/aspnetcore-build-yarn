FROM zeekozhu/aspnetcore-node-deps:5.0.0-preview.8.20414.8


ENV \
    # Unset the value from the base image
    ASPNETCORE_URLS= \
    # Disable the invariant mode (set in base image)
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip

RUN apk add --no-cache icu-libs alpine-sdk

ENV DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    FAKE_DETAILED_ERRORS=true \
    PATH="/root/.dotnet/tools:${PATH}"

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 5.0.100-preview.8.20417.9

RUN wget -O dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='72f73241456c7dafa11dfa4611461a9d83903c8407f447f0a504da5a518063f5336fcf0efc1ba86f979373ea8eac20c75da5c05e4c992ffb8a5fcdc8f427bc00' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help \
    && dotnet tool install -g fake-cli \
    && dotnet tool install -g paket
WORKDIR /