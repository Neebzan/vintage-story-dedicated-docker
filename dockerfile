FROM mcr.microsoft.com/dotnet/aspnet:7.0

RUN apt-get update && apt-get install -y \
    bash wget screen procps

RUN apt-get update && apt-get install -y jq

RUN addgroup --system vintagestory && \
    adduser --system --ingroup vintagestory vintagestory

RUN mkdir -p /app/data /app/server && \
    chown -R vintagestory:vintagestory /app/data /app/server

WORKDIR /app/server

RUN wget https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_1.20.3.tar.gz && \
    tar xzf vs_server_linux-x64_1.20.3.tar.gz && \
    chmod +x server.sh

RUN sed -i "s|^USERNAME='.*'|USERNAME='vintagestory'|" server.sh && \
    sed -i "s|^VSPATH='.*'|VSPATH='/app/server'|" server.sh && \
    sed -i "s|^DATAPATH='.*'|DATAPATH='/app/data'|" server.sh

COPY entrypoint.sh /app/server/entrypoint.sh

RUN chmod +x /app/server/entrypoint.sh

USER vintagestory

ENTRYPOINT ["/app/server/entrypoint.sh"]

