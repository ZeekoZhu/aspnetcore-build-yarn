FROM mcr.microsoft.com/dotnet/core/sdk:3.1.100

# set up environment
ENV ASPNETCORE_URLS http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip

ENV DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    FAKE_DETAILED_ERRORS=true \
    PATH="/root/.dotnet/tools:${PATH}"

RUN apt-get -qq update \
    && apt-get install -y build-essential --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# set up node
ENV NODE_VERSION 12.14.0
ENV YARN_VERSION 1.21.1
ENV NODE_DOWNLOAD_SHA 52207f643ab0fba66d5189a51aac280c4834c81f24a7297446896386ec93a5ed
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN wget "$NODE_DOWNLOAD_URL" -O nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help \
    && dotnet tool install -g fake-cli \
    && dotnet tool install -g paket

WORKDIR /
