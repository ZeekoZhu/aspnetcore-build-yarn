FROM zeekozhu/aspnetcore-node-deps:5.0.0-rc.1.20451.17

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.0-rc.1.20451.17 \
    DOTNET_VERSION=5.0.0-rc.1.20451.14

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='a7a393d31e8cc27def0f74ee743de2cdec3f8f8ae27e542c4517815e83dae7f5715f806fb169e8675126023efffbbb28d46cedac2c727b2bd1f8419598d25716' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='963ad9dbaa48e1224d53b7db3d8869de973e2d576368cb87ba95f3fafaa49cf36e1988eecaafe1e0efbd36f2cd3d9d171c39c5205ad93cdcdcf5a7c13860cef9' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
