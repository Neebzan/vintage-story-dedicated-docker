FROM mcr.microsoft.com/dotnet/aspnet:8.0

ARG UID=1000 
ARG GID=1000 

RUN apt-get update && apt-get install -y \
    bash screen procps curl

RUN apt-get update && apt-get install -y jq

# Create group and user with matching UID/GID
RUN addgroup --gid $GID vintagestory && \
    adduser --uid $UID --gid $GID --system vintagestory

RUN mkdir -p /app/data /app/server && \
    chown -R vintagestory:vintagestory /app/data /app/server

WORKDIR /app/server

COPY entrypoint.sh /app/server/entrypoint.sh

RUN chmod +x /app/server/entrypoint.sh

USER vintagestory

ENTRYPOINT ["/app/server/entrypoint.sh"]
