FROM node:14.15.4-alpine

ENV YARN_VERSION 1.22.5

RUN apk add libgdiplus-dev --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
        --allow-untrusted

RUN apk add --no-cache \
    ca-certificates \
    curl \
    # .NET Core dependencies
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    zlib

# Configure Kestrel web server to bind to port 80 when present
ENV ASPNETCORE_URLS=http://+:80 \
        # Enable detection of running in a container
        DOTNET_RUNNING_IN_CONTAINER=true \
        # Set the invariant mode since icu_libs isn't included (see https://github.com/dotnet/announcements/issues/20)
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

RUN apk add --no-cache --virtual .build-deps-yarn gnupg tar \
        && for key in \
        6A010C5166006599AA17F08146C2130DFD2497F5 \
        ; do \
        gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
        done \
        && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
        && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
        && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
        && mkdir -p /opt \
        && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
        && rm -f /usr/local/bin/yarn && rm -f /usr/local/bin/yarnpkg \
        && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
        && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
        && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
        && apk del .build-deps-yarn
