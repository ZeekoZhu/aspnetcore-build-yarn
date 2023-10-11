FROM mcr.microsoft.com/dotnet/aspnet:8.0.0-rc.2

# set up environment
ENV ASPNETCORE_URLS http://+:80

RUN apt-get -qq update \
    && apt-get install -y wget curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/ \
    && apt-get clean

# install volta
RUN curl https://get.volta.sh | bash

ENV VOLTA_HOME=/root/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

RUN volta install node@latest \
    && volta install yarn@latest \
    && volta list -d --format plain

WORKDIR /
