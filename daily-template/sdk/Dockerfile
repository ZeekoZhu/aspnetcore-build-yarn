FROM {{SdkImage}}

# set up environment
ENV ASPNETCORE_URLS http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip

ENV DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2 \
    FAKE_DETAILED_ERRORS=true \
    PATH="/root/.dotnet/tools:${PATH}"

RUN apt-get -qq update \
    && apt-get install -y build-essential --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# install volta
RUN curl https://get.volta.sh | bash

ENV VOLTA_HOME=/root/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

RUN volta install node@latest \
    && volta install yarn@latest \
    && volta list -d --format plain

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help \
    && dotnet tool install -g fake-cli \
    && dotnet tool install -g paket

WORKDIR /
