FROM mcr.microsoft.com/dotnet/aspnet:7.0

ARG UID=1001
ARG GID=1001

RUN apt-get update && apt-get install -y \
    bash wget screen procps

RUN apt-get update && apt-get install -y jq

RUN addgroup --gid $GID vintagestory && \
    adduser --uid $UID --gid $GID --system --ingroup vintagestory vintagestory

RUN mkdir -p /app/data /app/server && \
    chown -R vintagestory:vintagestory /app/data /app/server

WORKDIR /app/server

ENV VERSION "1.20.3"

RUN wget https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_${VERSION}.tar.gz && \
    tar xzf vs_server_linux-x64_${VERSION}.tar.gz && \
    chmod +x server.sh

RUN sed -i "s|^USERNAME='.*'|USERNAME='vintagestory'|" server.sh && \
    sed -i "s|^VSPATH='.*'|VSPATH='/app/server'|" server.sh && \
    sed -i "s|^DATAPATH='.*'|DATAPATH='/app/data'|" server.sh

COPY entrypoint.sh /app/server/entrypoint.sh

RUN chmod +x /app/server/entrypoint.sh

USER vintagestory

ENTRYPOINT ["/app/server/entrypoint.sh"]
