FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.10

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 14.15.3
ENV YARN_VERSION 1.22.5
ENV NODE_DOWNLOAD_SHA 439490022fed1ef0945240210c3a84725adcd24ff238325199118323462cb43d
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
