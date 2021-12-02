FROM node:16.13.1-alpine

ENV YARN_VERSION 1.22.15

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

RUN npm install -g yarn@$YARN_VERSION --force
