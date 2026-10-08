FROM chapel/chapel:latest

# Set environment variables
ENV ARKOUDA_DOWNLOAD_URL="https://github.com/Bears-R-Us/arkouda/archive/refs/tags/v2023.05.05.zip"
ENV NB_USER="jovyan"
ENV NB_UID="1000"
ENV NB_GID="100"


# Create a non-root user to run the Jupyter notebook
RUN useradd -m -s /bin/bash -N -u ${NB_UID} -g ${NB_GID} ${NB_USER}


# Install dependencies
RUN apt-get update &&  apt upgrade -y && \
    apt-get install unzip -y && \
    rm -rf /var/lib/apt/lists/*


# Download desired Arkouda distro, and unzip it
WORKDIR /opt
RUN wget $ARKOUDA_DOWNLOAD_URL -O  arkouda.zip && \
    unzip arkouda.zip  && \
    mv arkouda-* arkouda && \
    chmod -R 777 arkouda && \
    rm arkouda.zip 


# Install Arkouda
WORKDIR /opt/arkouda
RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir notebook 


# Setting Juypyter notebook configuration
COPY jupyter-autorun/* /etc/ipython/startup/
COPY jupyter_notebook_config.py /etc/jupyter/


# Switch to non-root user
USER ${NB_USER}
WORKDIR /home/${NB_USER}


# Start Jupyter notebook server
EXPOSE 8888
CMD ["python3","-m", "notebook", "--ip=*", "--no-browser"]
    