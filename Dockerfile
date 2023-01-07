# Build dotnet application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet-build
WORKDIR /App
COPY iConverter/ ./
COPY iConverter-test/ ./
RUN dotnet restore "iConverter.csproj"
RUN dotnet build "iConverter.csproj" -c Release -o /App/build --no-restore

# Publish dotnet application
FROM dotnet-build AS dotnet-publish
RUN ls
RUN dotnet publish "iConverter.csproj" -c Release -o /App/publish
RUN ls publish/

# Install npm dependencies and build
FROM node:19-alpine3.16 AS node-build
WORKDIR /Node
COPY ClientApp/ ./
RUN npm install
RUN npm run build

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
ENV ASPNETCORE_URLS=http://+:5188
WORKDIR /App
COPY --from=dotnet-publish /App/publish .
RUN ls
COPY --from=node-build /Node/build .
EXPOSE 5188
ENTRYPOINT ["dotnet", "iConverter.dll"]
