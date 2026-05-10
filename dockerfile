FROM mcr.microsoft.com/dotnet/aspnet:10.0

RUN apt-get update && apt-get install -y \
    bash screen procps curl jq

WORKDIR /app/server

COPY entrypoint.sh /app/server/entrypoint.sh
RUN chmod +x /app/server/entrypoint.sh

ENTRYPOINT ["/app/server/entrypoint.sh"]
