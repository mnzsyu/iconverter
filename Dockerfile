# Build dotnet application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet-build
WORKDIR /App
COPY . ./
RUN ls
RUN dotnet restore "iConverter/iConverter.csproj"
RUN dotnet build "iConverter/iConverter.csproj" -c Release -o dotnet-build/

# Install npm dependencies and build
FROM node:19-alpine3.16 AS node-build
WORKDIR /Node
COPY iConverter/ClientApp /Node
RUN npm install
RUN npm run build

# Publish dotnet application
FROM dotnet-build AS dotnet-publish
COPY --from=node-build /Node/build node-build/
RUN dotnet publish "iConverter/iConverter.csproj" -c Release -o publish/

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
ENV ASPNETCORE_URLS=http://+:5188
WORKDIR /App
COPY --from=dotnet-publish /App/publish .
EXPOSE 5188
ENTRYPOINT ["dotnet", "iConverter.dll"]
