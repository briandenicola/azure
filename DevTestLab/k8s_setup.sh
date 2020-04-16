#!/bin/bash

echo supersede domain-name \" bjdazure.demo\"\; >> /etc/dhcp/dhclient.conf
export addr=`ip addr | grep eth0 | grep inet | awk '{print $2}' | cut -d '/' -f 1`
echo $addr `hostname` >> /etc/hosts
systemctl restart network

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

setenforce 0

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce kubelet kubeadm kubectl
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

sed -s s/systemd/cgroupfs/g /etc/systemd/system/kubelet.service.d/10-kubeadm.conf >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bak
mv /etc/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.org
mv /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bak /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet

sleep 5

kubeadm init 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config 

sleep 10

kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml 
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default