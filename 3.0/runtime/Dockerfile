FROM mcr.microsoft.com/dotnet/core/aspnet:3.0

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 12.4.0
ENV YARN_VERSION 1.16.0
ENV NODE_DOWNLOAD_SHA 78c12398128e79dfec3092325da026d422d296c9d3089a9b2ee7bf7bd2e3be87
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

WORKDIR /
