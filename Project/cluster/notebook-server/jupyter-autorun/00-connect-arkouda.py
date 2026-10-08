import os
import arkouda as ak


# Read the ARKOUDA_ENDPOINT environment variable
arkouda_endpoint = os.getenv('ARKOUDA_SERVER_PORT')

if arkouda_endpoint:
    try:
        # Attempt to connect to the Arkouda server using the endpoint
        ak.connect(connect_url=arkouda_endpoint, timeout=5)
    except ConnectionError as e:
        raise ConnectionError("Failed to connect to the Arkouda server.") from e
else:
    raise ValueError ("ARKOUDA_ENDPOINT environment variable is not set. Cannot connect to Arkouda server.")
