FROM mcr.microsoft.com/dotnet/sdk:5.0.408-alpine3.15

ENV \
    # Unset the value from the base image
    ASPNETCORE_URLS= \
    # Disable the invariant mode (set in base image)
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip

RUN apk add --no-cache icu-libs alpine-sdk

ENV DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    FAKE_DETAILED_ERRORS=true \
    PATH="/root/.dotnet/tools:${PATH}"

# install volta
RUN curl https://get.volta.sh | bash

ENV VOLTA_HOME $HOME/.volta
ENV PATH $VOLTA_HOME/bin:$PATH

RUN volta install node@latest \
    && volta install yarn@latest \
    && volta list -d --format plain

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help \
    && dotnet tool install -g fake-cli --version 5.20.4 \
    && dotnet tool install -g paket
WORKDIR /
