FROM localhost:5000/baseline-image.common:2ak24.3ch2  as common
COPY --from=localhost:5000/baseline-image.clean:2ak24.3ch2 /opt/arkouda /opt/arkouda
COPY --from=localhost:5000/baseline-image.clean:2ak24.3ch2 /opt/arkouda-contrib /opt/arkouda-contrib
COPY --from=localhost:5000/baseline-image.clean:2ak24.3ch2 /opt/chapel/third-party/gasnet/install/linux64-x86_64-unknown-llvm-none/substrate-udp/seg-everything/bin/amudprun /opt/chapel/third-party/gasnet/install/linux64-x86_64-unknown-llvm-none/substrate-udp/seg-everything/bin/amudprun 

RUN apt-get update && apt upgrade -y && \
    apt-get install openssh-server wget libcurl4-openssl-dev -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/arkouda
RUN pip install --no-cache-dir -e . && \ 
    pip install --no-cache-dir -e /opt/arkouda-contrib/arkouda_integration/client

# ---------------------------------------
FROM common as test

RUN apt-get update && apt upgrade -y && \
    apt-get install openssh-server wget libcurl4-openssl-dev -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

ADD scripts/test-arkouda.sh /opt/arkouda/test-arkouda.sh
RUN chmod +x /opt/arkouda/test-arkouda.sh
RUN /opt/arkouda/test-arkouda.sh2

# ---------------------------------------
FROM common as runtime

WORKDIR /opt
ADD scripts/start-arkouda-server.sh /opt/arkouda/start-arkouda-server.sh
ADD scripts/start-arkouda-locale.sh /opt/arkouda/start-arkouda-locale.sh
ENTRYPOINT sh /opt/arkouda/start-arkouda-server.sh      