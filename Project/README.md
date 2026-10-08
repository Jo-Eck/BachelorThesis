# Project Documentation

This section contains the code, configuration and data analysis for the Prototype and Thesis.

It is split into the following sections:

- [Arkouda Server](./cluster/arkouda-server/README.md) - Which contains the Deployments and configuration of the HPC Side of the Cluster
- [Baseline Image](./cluster/baseline-image) - Which is an optimized version of the chapel image which is needed for the Arkouda Server
- [Infiniband CNI](./cluster/infiniband-cni/installing-infiniband-cni.ipynb) - Contains the section of the project which enables the HPC network interconnect to be utilized by the Kubernetes Cluster
- [Notebook Server](./cluster/notebook-server/) - Is the custom container to provide interactive access to the compute cluster, without going through the GitOps pipeline
- [Singularity OCI](./cluster/singularity-oci/readme.ipynb) - Contains the attempt to utilize Multi Container OCI images in Kubernetes to run Singularity Containers
- [Testing](./cluster/testing/) and [Data](./data/) - Contain the code and raw data for the performance testing of the Arkouda Server and the containers


## Project Infrastructure

The Cluster itself is based on the Pachyderm worklflow management tool, which is used to trigger the Jobs when new data is pushed to the cluster.
It is extendet by a fleet of Arkouda worker containers and supporting infrastucture to provide a complete usable environment as shown in the following diagram:

![Cluster Infrastructure](../Paper/graphics/Pachykouda%20-%20High%20level%20architecture.png)

For more information on the individual components, please refer to the respective sections.