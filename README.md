# Interactive Converged HPC

My bachelor's thesis at DHBW Stuttgart, written with the Systems Architecture Lab at Hewlett Packard Labs in Milpitas, California, in 2024. It was graded 1.4, the top grade band.

**The question:** can data scientists explore HPC-scale data interactively, from a Jupyter notebook, on a cloud-native Kubernetes platform, without losing the speed of HPC frameworks?

**What I built:** a bare-metal Kubernetes cluster that runs a fleet of [Arkouda](https://github.com/Bears-R-Us/arkouda) workers, plus a Jupyter notebook server that talks to them directly. Arkouda is a Python and Chapel framework for parallel data analysis. The prototype extends Pachykouda, the GitOps pipeline system from my earlier project paper, so users can explore data interactively instead of going through the pipeline.

**A result I like:** multi-stage builds shrank the Arkouda container image from 2.86 GB to 710 MB. That cut the median cold start of a worker from 63.5 to 19.7 seconds, a 69% reduction.

## Contents

- [`Paper/thesis.pdf`](Paper/thesis.pdf): the thesis as graded.
- [`project-paper.pdf`](project-paper.pdf): the project paper that came before it, on running Arkouda in the Pachyderm workflow orchestrator. It was graded 1.3.
- [`Project/`](Project/README.md): cluster configuration, container images, Helm charts, the InfiniBand network setup and the benchmark notebooks.
- [`Paper/`](Paper/): LaTeX sources and figures.

The lab cluster this ran on has been taken down. Its internal hostnames and addresses in the configuration are replaced with placeholders such as `node20.lab.example`.

## Acknowledgements

Practice supervisor: Dr. Harumi Kuno, Hewlett Packard Labs. Academic supervisor: Dominic Viola, DHBW Stuttgart.
