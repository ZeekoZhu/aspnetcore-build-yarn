FROM mcr.microsoft.com/dotnet/aspnet:6.0.5-alpine3.15

# install volta
RUN curl https://get.volta.sh | bash

ENV VOLTA_HOME $HOME/.volta
ENV PATH $VOLTA_HOME/bin:$PATH

RUN volta install node@latest \
    && volta install yarn@latest \
    && volta list -d --format plain
