FROM mcr.microsoft.com/dotnet/aspnet:3.1.20

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 16.13.0
ENV YARN_VERSION 1.22.15
ENV NODE_DOWNLOAD_SHA 589b7e7eb22f8358797a2c14a0bd865459d0b44458b8f05d2721294dacc7f734
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
