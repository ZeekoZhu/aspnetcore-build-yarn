FROM microsoft/dotnet:2.1-sdk

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.1.1

# set up node
ENV NODE_VERSION 8.11.3
ENV YARN_VERSION 1.7.0
ENV NODE_DOWNLOAD_SHA 1ea408e9a467ed4571730e160993f67a100e8c347f6f9891c9a83350df2bf2be
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

RUN wget "$NODE_DOWNLOAD_URL" -O nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA  nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && npm i -g yarn@$YARN_VERSION \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# install bzip2
RUN curl -O "http://ftp.us.debian.org/debian/pool/main/b/bzip2/bzip2_1.0.6-8.1_amd64.deb" \
    && dpkg -i bzip2_1.0.6-8.1_amd64.deb \
    && rm bzip2_1.0.6-8.1_amd64.deb

# warmup NuGet package cache
COPY packagescache.csproj /tmp/warmup/
RUN dotnet restore /tmp/warmup/packagescache.csproj \
      --source https://api.nuget.org/v3/index.json \
      --verbosity quiet \
    && rm -rf /tmp/warmup/

WORKDIR /
