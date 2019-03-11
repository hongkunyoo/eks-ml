CLUSTER_NAME=eks-ml

echo '>>>>>>>> Installing Cluster auto scaler >>>>>>>>>'
NG_ID=$(eksctl get nodegroup --cluster $CLUSTER_NAME | cut -d ' ' -f1 | sed 1d | cut -f2)
NG_STACK=eksctl-$CLUSTER_NAME-nodegroup-$NG_ID
ASG_ID=$(aws cloudformation describe-stack-resource --stack-name $NG_STACK --logical-resource-id NodeGroup --query StackResourceDetail.PhysicalResourceId --output text)

aws autoscaling create-or-update-tags --tags ResourceId=$ASG_ID,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=,PropagateAtLaunch=true
aws autoscaling create-or-update-tags --tags ResourceId=$ASG_ID,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/$CLUSTER_NAME,Value=,PropagateAtLaunch=true

NODE_ROLE=$(aws cloudformation describe-stack-resource --stack-name $NG_STACK --logical-resource-id NodeInstanceRole --query StackResourceDetail.PhysicalResourceId --output text)
aws iam put-role-policy --role-name $NODE_ROLE --policy-name autoscale --policy-document '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow",  "Action": [ "autoscaling:*" ], "Resource": "*" } ] }'

helm install stable/cluster-autoscaler --name autoscale --namespace kube-system --set autoDiscovery.clusterName=$CLUSTER_NAME,awsRegion=ap-northeast-2,sslCertPath=/etc/kubernetes/pki/ca.crt
echo '>>>>>>>> done >>>>>>>>>'
