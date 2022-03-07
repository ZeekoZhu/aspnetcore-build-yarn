FROM zeekozhu/aspnetcore-node-deps:5.0.14

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.14 \
    DOTNET_VERSION=5.0.14

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='1136ac2a2686a6a16406899b118adcde0aea0341c7d4e781b256543fc1517bb116128497103d7456dfac632c3e75a7ad9d00b570bfd77ed9fbc7ef239f67940c' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='fbde931a95063b3ca2bb264af8c3b19ef85ea4f5e2e09b6669a39f3c08c4eba43a89dd2c64bc9f4ffb49d41f678c6654d1b5c1dcc35430091773983f8bd97473' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
