FROM localhost:5000/baseline-image.common:1ak24.3ch2  as common
COPY --from=localhost:5000/baseline-image.clean:1ak24.3ch2 /opt/arkouda /opt/arkouda

ENV NB_GID="100"
ENV NB_UID="1000"   
ENV NB_USER="jovyan"

WORKDIR /opt/arkouda    
RUN useradd -m -s /bin/bash -N -u ${NB_UID} -g ${NB_GID} ${NB_USER}
RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir notebook

# Switch to non-root user
USER ${NB_USER}
WORKDIR /home/${NB_USER}

# Clean up
# RUN rm -rf benchmarks converter examples *.md pictures pydoc resources runs src test tests toys

COPY jupyter-autorun/* /etc/ipython/startup/
COPY jupyter_notebook_config.py /etc/jupyter/

# Start Jupyter notebook server
EXPOSE 8888
CMD ["python3","-m", "notebook", "--ip=*", "--no-browser"]
