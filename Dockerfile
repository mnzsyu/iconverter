# Build dotnet application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet-build
WORKDIR /App
COPY . ./
RUN dotnet restore "iConverter/iConverter.csproj"
RUN dotnet build "iConverter/iConverter.csproj" -c Release -o /App/build

# Publish dotnet application
FROM dotnet-build AS dotnet-publish
RUN dotnet publish "iConverter/iConverter.csproj" -c Release -o /App/publish

# Install npm dependencies and build
FROM node:19-alpine3.16 AS node-build
WORKDIR /Node
COPY iConverter/ClientApp /Node
RUN npm install
RUN npm run build

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
ENV ASPNETCORE_URLS=http://+:5188
WORKDIR /App
COPY --from=dotnet-publish /App/publish .
COPY --from=node-build /Node/build .
EXPOSE 5188
ENTRYPOINT ["dotnet", "iConverter.dll"]
