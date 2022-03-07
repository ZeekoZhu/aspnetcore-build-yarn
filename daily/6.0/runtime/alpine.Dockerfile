FROM zeekozhu/aspnetcore-node-deps:6.0.2

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=6.0.2 \
    DOTNET_VERSION=6.0.2

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='fd298bb310f86969f88807ea907cb20a38d6ab4b24493800bdf026933634a5145aff076dbfe9acb3ab6aa3a48747eca3149e05334847871889a8312e6e8d706f' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='8fb985bf79039cb1848604f08976ad82ff9582b0379cc7047f5bc95fa9e2a50f88b608efdb1b39d626b5e2a4615e38bee720a83f2d263f4dfb6716e65c74fa73' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
