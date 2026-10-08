FROM localhost:5000/baseline-image.common:2ak24.3ch2  as common
COPY --from=localhost:5000/baseline-image.clean:2ak24.3ch2 /opt/arkouda /opt/arkouda

RUN apt-get update && apt upgrade -y && apt-get install -y --no-install-recommends \
    binutils     \ 
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/arkouda
RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir pytest pytest-benchmark pytest-env

COPY scripts/benchmark.ini /opt/arkouda/benchmark.ini
COPY scripts/benchmark.sh  /opt/benchmark.sh

RUN sed -i 's/ARKOUDA_SERVER_PORT/ARKOUDA_SERVER_SERVICE_PORT/g; s/ARKOUDA_SERVER_HOST/ARKOUDA_SERVER_SERVICE_HOST/g' /opt/arkouda/tests/conftest.py /opt/arkouda/benchmark_v2/conftest.py 
RUN sed -i 's/2\*\*30/2\*\*35/g' /opt/arkouda/arkouda/client.py

CMD ["bash", "/opt/benchmark.sh"]