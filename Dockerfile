FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Dependências base
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    make \
    gcc \
    g++ \
    autoconf \
    automake \
    libtool \
    pkg-config \
    curl \
    libcurl4-openssl-dev \
    libcups2-dev \
    libssl-dev \
    libpcre3-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    libpq-dev \
    libncurses5-dev \
    libreadline-dev \
    libxcb1-dev \
    libx11-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala MariaDB (Ubuntu >= 20) ou MySQL client (Ubuntu 18.04)
RUN . /etc/os-release && \
    apt-get update && \
    if [ "$VERSION_ID" = "18.04" ]; then \
        echo "Ubuntu 18.04 detectado -> usando libmysqlclient-dev"; \
        apt-get install -y libmysqlclient-dev; \
    else \
        echo "Ubuntu ${VERSION_ID} detectado -> usando libmariadb-dev"; \
        apt-get install -y \
            libmariadb-dev \
            libmariadb-dev-compat; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Clona o Harbour
RUN git clone https://github.com/harbour/core.git /opt/harbour-core

WORKDIR /opt/harbour-core

# Build do Harbour
RUN make \
    HB_WITH_CURL=yes \
    HB_WITH_ZLIB=yes \
    HB_WITH_BZIP2=yes \
    HB_WITH_OPENSSL=yes \
    HB_WITH_PCRE=yes \
    HB_WITH_CUPS=yes \
    HB_WITH_SQLITE3=yes \
    HB_WITH_POSTGRESQL=yes \
    HB_WITH_PGSQL=yes \
    HB_WITH_MYSQL=yes \
    HB_WITH_X11=yes \
    HB_BUILD_DYN=yes \
    HB_BUILD_CONTRIBS=yes \
    HB_BUILD_ALL=yes && \
    make install

# Configuração do linker
RUN echo "/usr/local/lib/harbour" > /etc/ld.so.conf.d/harbour.conf && ldconfig

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /workspace

