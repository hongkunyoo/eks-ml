# eks-ml
AWS summit seoul 2019 - How to scale your ml job with Amazon EKS

- `setup.sh`: setup script before demo
- `train.py`: model script to train
- `train-oom.py`: model script to demonstrate OOM error
- `exp01.yaml`: example of kubernetes job
- `oom.yaml`: example of OOM killed job
- `experiments.yaml`: list of experiment to train
- `run-experiments.py`: python code to run experiments
- `Dockerfile`: file to make docker image [`hongkunyoo/eks-ml`](https://hub.docker.com/r/hongkunyoo/eks-ml)
