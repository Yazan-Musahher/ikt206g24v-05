# Use the latest LTS version of Ubuntu as the base image   
FROM ubuntu:22.04 AS build
# Install the required dependencies

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        ca-certificates
        
# Install additional dependencies
RUN apt-get upgrade -y && apt install sudo -y

# Download and install the .NET SDK
RUN sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-8.0

# Download and install the .NET runtime
RUN sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-8.0
  
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore /p:IsDockerBuild=true

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out /p:IsDockerBuild=true

FROM ubuntu:22.04

WORKDIR /app

# Download and install the .NET runtime in the runtime stage
RUN apt-get update && \
  apt-get install -y aspnetcore-runtime-8.0 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Corrected line: Copy the built app from the 'build' stage
COPY --from=build /app/out .

# Expose the port your app runs on
EXPOSE 80

# Command to run the application
ENTRYPOINT ["dotnet", "Example.dll"]