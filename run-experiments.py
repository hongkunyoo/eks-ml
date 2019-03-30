import os
import yaml

JOB_TEMPLATE = \
"""cat << EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: exp%02d-%s
spec:
  template:
    spec:
      containers:
      - name: ml
        image: %s
        command: ["python", "train.py"]
        args: ['%s', '%s', '%s']
        imagePullPolicy: Always
        resources:
          limits:
            cpu: "1"
            memory: "7Gi"
      restartPolicy: Never
EOF
"""

with open('experiments.yaml') as f:
    experiments = yaml.load(f)

count = 1
for exp in experiments:
    for idx, arg in enumerate(exp['args']):
        model_name = exp['script'].split(':')[-1]
        run_job_cmd = JOB_TEMPLATE % tuple([count, model_name, exp['script'], *arg])
        ######################
        # Run exp
        ######################
        os.system(run_job_cmd)
        count += 1
