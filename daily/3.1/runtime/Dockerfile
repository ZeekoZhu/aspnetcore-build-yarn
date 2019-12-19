FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.0

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 12.14.0
ENV YARN_VERSION 1.21.1
ENV NODE_DOWNLOAD_SHA 52207f643ab0fba66d5189a51aac280c4834c81f24a7297446896386ec93a5ed
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

WORKDIR /
