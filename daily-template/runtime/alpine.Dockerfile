FROM {{AspNetImage}}-alpine3.15

# install volta
RUN curl https://get.volta.sh | bash

ENV VOLTA_HOME=/root/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

RUN volta install node@latest \
    && volta install yarn@latest \
    && volta list -d --format plain
