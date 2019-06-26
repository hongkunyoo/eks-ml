# eks-ml
AWS summit seoul 2019 - How to scale your ml job with Amazon EKS
SlideShare: https://pt.slideshare.net/awskorea/amazon-eks-lg-aws-summit-seoul-2019
Video: https://www.youtube.com/watch?v=egv2TlfLL1Y&list=PLORxAVAC5fUWyB6Hsk9ibYJHw97k1h6s9&index=46

- `setup.sh`: setup script before demo
- `train.py`: model script to train
- `train-oom.py`: model script to demonstrate OOM error
- `example.yaml`: example of kubernetes job
- `oom.yaml`: example of OOM killed job
- `experiments.yaml`: list of experiment to train
- `run-experiments.py`: python code to run experiments
- `Dockerfile`: file to make docker image [`hongkunyoo/eks-ml`](https://hub.docker.com/r/hongkunyoo/eks-ml)
- `Dockerfile.oom`: file to make OOM training image [`hongkunyoo/eks-ml:oom`](https://hub.docker.com/r/hongkunyoo/eks-ml)


---

#### 1. Configuration
Install awscli & configure `ACCESS_KEY` and `SECRET_KEY`.
The user should have following permissions.
- EKS full access
- CloudFormation full access
- EC2 full access
- IAM full access
> these permissions are quite administrative. please use it at your own risk.

#### 2. Setup
Run `setup.sh` as sudo user.
```bash
sudo ./setup.sh
```

#### 3. Hello world
Apply first example of job
```bash
kubectl apply -f example.yaml
```

#### 4. Run all
Run all experiments
```bash
python run-experiments.py
```
