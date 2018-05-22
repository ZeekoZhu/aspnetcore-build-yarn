# Sample contents of Dockerfile
# Stage 1
FROM zeekozhu/aspnetcore-build-yarn:2.1 AS builder
WORKDIR /source

# caches restore result by copying csproj file separately
COPY *.csproj .
COPY ./ClientApp/*.json ./ClientApp/
COPY ./ClientApp/yarn.lock ./ClientApp/

RUN dotnet restore && cd ClientApp && yarn

# copies the rest of your code
COPY . .
RUN dotnet publish --output /app/ --configuration Release

# Stage 2
FROM zeekozhu/aspnetcore-node:2.1
WORKDIR /app
COPY --from=builder /app .
ENTRYPOINT ["dotnet", "myapp.dll"]
