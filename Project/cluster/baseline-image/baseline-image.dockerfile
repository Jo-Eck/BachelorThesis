FROM python:slim-bullseye as common

ENV CHPL_VERSION=2.0.0
ENV ARKOUDA_VERSION="v2024.03.18"


ENV ARKOUDA_INTEGRATION_DOWNLOAD_URL="https://github.com/Bears-R-Us/arkouda-contrib/archive/275aee24279dd76eae99d2670230e2e2558e39ea.zip"
ENV ARKOUDA_URL="https://github.com/Bears-R-Us/arkouda/archive/refs/tags/$ARKOUDA_VERSION.zip"
ENV CHPL_URL="https://github.com/chapel-lang/chapel/releases/download/$CHPL_VERSION/chapel-$CHPL_VERSION.tar.gz"

ENV CHPL_HOME=/opt/chapel
ENV CHPL_COMM_SUBSTRATE=udp
ENV CHPL_COMM=gasnet
ENV CHPL_LAUNCHER=amudprun
ENV CHPL_LLVM=system
ENV CHPL_RE2=bundled
ENV CHPL_GMP=system

ENV DEBIAN_FRONTEND=noninteractive

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" 
RUN chmod -R 777 /opt

ENV SSH_SERVERS=0.0.0.0
ENV GASNET_MASTERIP=0.0.0.0

FROM common as build 
# ---------------------------------------
RUN apt-get update && apt upgrade -y && \
    python3 -m pip install --no-cache-dir --upgrade pip && \
    apt-get install \
    bash \
    ca-certificates \
    clang \
    cmake \
    curl \
    dnsutils \
    file \
    g++ \
    gcc \
    git \
    hdf5-tools \
    libclang-cpp-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libgmp-dev \
    libgmp10 \
    lld \
    lldb \
    llvm \
    llvm-dev \
    locales \
    m4 \
    make \
    mawk \
    openssh-client \
    openssh-server \
    perl \
    pkg-config \
    procps \
    python-setuptools \
    python3 \
    python3-dev \
    python3-pip \
    ssh \
    sshpass \
    sudo \
    unzip \
    vim \
    wget \
    -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Build Chapel
RUN mkdir -p /opt/chapel \
    && wget -q -O - $CHPL_URL | tar -xzC /opt/chapel --strip-components=1 \
    && make  -C /opt/chapel \
    && make -C /opt/chapel cleanall
ENV PATH=/opt/chapel/bin/linux64-x86_64/:$PATH

RUN ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Download desired Arkouda distro, move to common /opt/arkouda dir
RUN wget -q $ARKOUDA_URL -O  arkouda.zip && \
    unzip arkouda.zip  && \
    mv arkouda-* /opt/arkouda && \
    chmod -R 777 /opt/arkouda && \
    rm arkouda.zip  && \    
    make install-deps -C /opt/arkouda && \
    service ssh start && \
    make -C /opt/arkouda && \
    python3 -m pip install --no-cache-dir -e /opt/arkouda[dev]
    
# Download and prepare Arkouda integration
RUN wget -q $ARKOUDA_INTEGRATION_DOWNLOAD_URL -O arkouda-integration.zip && \
    unzip arkouda-integration.zip && \
    mv arkouda-contrib-* /opt/arkouda-contrib && \
    chmod -R 777  /opt/arkouda-contrib && \
    rm arkouda-integration.zip

RUN pip install --no-cache-dir parquet

# --------------------------------------- 
FROM common as clean 

COPY --from=build /opt /opt

# ---------------------------------------   