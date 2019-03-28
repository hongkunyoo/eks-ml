if bash -c '[[ $EUID -ne 0 ]]'; then
   echo "This script must be run as sudo" 
   exit 1
fi

CLUSTER_NAME=eks-ml

# installing eksctl
echo '####################################'
echo '>>>>>>>> Installing eksctl >>>>>>>>>'
echo '####################################'
curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin


# installing heptio-authenticator
echo '####################################################'
echo '>>>>>>>> Installing aws-iam-authenticator >>>>>>>>>>'
echo '####################################################'
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mv aws-iam-authenticator /usr/local/bin


# installing kubectl
echo '######################################'
echo '>>>>>>>> Installing kubectl >>>>>>>>>>'
echo '######################################'
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl


# installing helm client
echo '#########################################'
echo '>>>>>>>> Installing helm client >>>>>>>>>'
echo '#########################################'
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash


# k8s cluster
echo '#######################################'
echo '>>>>>>>> Creating k8s cluster >>>>>>>>>'
echo '#######################################'
echo "eksctl create cluster --name $CLUSTER_NAME --node-type m5.xlarge --nodes-min=6 --nodes-max=12"
echo '>>>>>>>> This will take a while (about 15 min)'
eksctl create cluster --name $CLUSTER_NAME --node-type m5.xlarge --nodes-min=6 --nodes-max=12
sleep 20

#echo '#########################################'
#echo '>>>> Labeling nodes (cpu, mem, gpu) >>>>>'
#echo '#########################################'
#for node in $(kubectl get node | cut -d ' ' -f1 | sed 1d)
#do
#    ml_type=$(echo cpu mem gpu | xargs shuf -n1 -e)
#    kubectl label node $node ml-type=$ml_type
#done



# installing metric server
echo '###########################################'
echo '>>>>>>>> Installing metric server >>>>>>>>>'
echo '###########################################'
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
helm install stable/metrics-server --name stats --namespace kube-system --set 'args={--logtostderr,--metric-resolution=2s}'
chown $SUDO_UID:$SUDO_GID $HOME/.kube/config
chown -R $SUDO_UID:$SUDO_GID $HOME/.helm


echo '########################################'
echo '>>>>>>>> Get AutoScaleGroup ID >>>>>>>>>'
echo '########################################'
NG_ID=$(eksctl get nodegroup --cluster $CLUSTER_NAME | cut -d ' ' -f1 | sed 1d | cut -f2)
NG_STACK=eksctl-$CLUSTER_NAME-nodegroup-$NG_ID
ASG_ID=$(aws cloudformation describe-stack-resource --stack-name $NG_STACK --logical-resource-id NodeGroup --query StackResourceDetail.PhysicalResourceId --output text)


echo '#################################################'
echo '>>>>>>>> Tag cluster-autoscaler/enabled >>>>>>>>>'
echo '#################################################'
aws autoscaling create-or-update-tags --tags ResourceId=$ASG_ID,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=,PropagateAtLaunch=true
aws autoscaling create-or-update-tags --tags ResourceId=$ASG_ID,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/$CLUSTER_NAME,Value=,PropagateAtLaunch=true

NODE_ROLE=$(aws cloudformation describe-stack-resource --stack-name $NG_STACK --logical-resource-id NodeInstanceRole --query StackResourceDetail.PhysicalResourceId --output text)
aws iam put-role-policy --role-name $NODE_ROLE --policy-name autoscale --policy-document '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow",  "Action": [ "autoscaling:*" ], "Resource": "*" } ] }'


echo '################################################'
echo '>>>>>>>> Installing cluster-autoscaler >>>>>>>>>'
echo '################################################'
cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-system-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
EOF

helm install stable/cluster-autoscaler --name autoscale --namespace kube-system --set autoDiscovery.clusterName=$CLUSTER_NAME,awsRegion=ap-northeast-2,sslCertPath=/etc/kubernetes/pki/ca.crt

echo '################################'
echo '>>>>>>>>>>>>> done >>>>>>>>>>>>>'
echo '################################'

