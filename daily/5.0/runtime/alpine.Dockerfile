FROM zeekozhu/aspnetcore-node-deps:5.0.17

# Install ASP.NET Core
ENV ASPNETCORE_VERSION=5.0.17 \
    DOTNET_VERSION=5.0.17

RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='e40ef40ebc7394cc7ef9eb9ce26b16a73bf99d597d98df009a06fff5d4fcec307e094ef6e780e8a2169351d9a93c92c18f20975fd1c6d75669218a29257fb6df' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

RUN wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='7df763553f6438c51f23542412830686fef82b56f1e3330fa2dfd86b894eff7d830b5ff51468cfe6e88d2eceebc0a0a2352c8762f65a0ffc6ca9f5b02863b7a6' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
