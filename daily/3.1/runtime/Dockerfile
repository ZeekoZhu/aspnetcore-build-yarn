FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.6

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 12.18.2
ENV YARN_VERSION 1.22.4
ENV NODE_DOWNLOAD_SHA 2d316e55994086e41761b0c657e0027e9d16d7160d3f8854cc9dc7615b99a526
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

WORKDIR /
