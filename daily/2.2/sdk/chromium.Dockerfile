FROM mcr.microsoft.com/dotnet/core/sdk:2.2

# set up environment
ENV ASPNETCORE_URLS http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip \
    PATH="${PATH}:/root/.dotnet/tools" \
    DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    FAKE_DETAILED_ERRORS=true \
    CHROME_BIN=/usr/bin/chromium

# set up node
ENV NODE_VERSION 12.4.0
ENV YARN_VERSION 1.16.0
ENV NODE_DOWNLOAD_SHA 9a16909157e68d4e409a73b008994ed05b4b6bc952b65ffa7fbc5abb973d31e9
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN wget "$NODE_DOWNLOAD_URL" -O nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Install chromium
RUN apt-get -qq update \
    && apt-get install -y chromium --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help

WORKDIR /
