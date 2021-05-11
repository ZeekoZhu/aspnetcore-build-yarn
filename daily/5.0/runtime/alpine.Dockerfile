FROM zeekozhu/aspnetcore-node-deps:5.0.6

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.6 \
    DOTNET_VERSION=5.0.6

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='13316e039b04b04c9def1f3a17c6391fd2fe6a6264528eba24b9cf6967ab292e4c4c8adc4ab2e032586f94e5f0ef0dfcf7315cb5cc324ec672bede0f16713f41' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='c4377df5b5b2e9d93e4a3c3b30bd42a17af86c1428e9a911a6e69a6441eca9f4163d05a9056cdeed0cf735819a6d01013b3ac35545f20f5a1fe87629cb3c3b18' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
