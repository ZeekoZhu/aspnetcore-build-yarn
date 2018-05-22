# Sample contents of Dockerfile
# Stage 1
FROM zeekozhu/aspnetcore-build-yarn:2.0 AS builder
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
FROM microsoft/aspnetcore
WORKDIR /app
COPY --from=builder /app .
ENTRYPOINT ["dotnet", "myapp.dll"]
