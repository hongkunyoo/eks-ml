# installing eksctl
echo '>> Installing eksctl...'
curl --silent --location "[https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$](https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$)(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
echo '>> done'


# installing heptio-authenticator
echo '>> Installing heptio authenticator...'
wget [https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64) -O heptio-authenticator-aws 
chmod +x heptio-authenticator-aws 
mv heptio-authenticator-aws /usr/local/bin/
echo '>> done'


# installing helm client
echo '>> Installing helm client...'
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
echo '>> done'


# k8s cluster
echo '>> Creating k8s cluster...'
echo 'eksctl create cluster --name eks-ml --nodes 20 --node-type m5.xlarge'
echo '>> This will take a while'
eksctl create cluster --name eks-ml --nodes 20 --node-type m5.xlarge
sleep 20

for node in $(kubectl get node | cut -d ' ' -f1 | sed 1d)
do
    ml_type=$(echo cpu mem gpu | xargs shuf -n1 -e)
    kubectl label node $node ml-type=$ml_type
done

echo '>> done'


# installing metric server
echo '>> Installing metirc server...'
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
EOF

helm init --service-account tiller
sleep 20
helm install stable/metrics-server --name stats --namespace kube-system --set args={--logtostderr,--metric-resolution=2s}
echo '>> done'
