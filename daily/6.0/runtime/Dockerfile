FROM mcr.microsoft.com/dotnet/aspnet:6.0.5

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 16.15.0
ENV YARN_VERSION 1.22.18
ENV NODE_DOWNLOAD_SHA d1c1de461be10bfd9c70ebae47330fb1b4ab0a98ad730823fb1340e34993edee
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN apt-get -qq update \
    && apt-get install -y wget curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/

RUN wget "$NODE_DOWNLOAD_URL" -O nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

WORKDIR /
