FROM zeekozhu/aspnetcore-node-deps:5.0.16

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.16 \
    DOTNET_VERSION=5.0.16

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='49310a377cb112375519477fe9a668fd45dabf560ed55659b56e557afc3e33e030ec683bc046314d86424f699c0987c55630a5155874351feffa91deefdf53f2' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='d7aa3a3753505448cc3ba38bc17bf767503e328fade8e8bbc6ac5da8e12ec29737159ec75d327ee71e7f628282a272df0fb4b20e296edbb5f282d2db859a1457' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
