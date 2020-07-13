# Install prerequisites
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes upgrade
sudo snap install microk8s --classic
sudo snap install docker
sudo microk8s.enable helm3
sudo microk8s.enable dns
sudo usermod -a -G microk8s vagrant
sudo chown -f -R vagrant ~/.kube

# Install OpenFaaS
sudo microk8s.kubectl apply -f /vagrant/namespaces.yml
sudo microk8s.helm3 repo add openfaas https://openfaas.github.io/faas-netes/
sudo microk8s.helm3 repo update
sleep 2
sudo microk8s.kubectl -n openfaas create secret generic basic-auth --from-literal=basic-auth-user=admin --from-literal=basic-auth-password=password
sleep 5
sudo microk8s.helm3 upgrade openfaas --install openfaas/openfaas --namespace openfaas --set functionNamespace=openfaas-fn --set basic_auth=true
while [ $? -ne 0 ]; do sudo microk8s.helm3 upgrade openfaas --install openfaas/openfaas --namespace openfaas --set functionNamespace=openfaas-fn --set basic_auth=true; done
sleep 120
sudo microk8s.kubectl -n openfaas rollout status -w deployment/faas-idler

# Install NATS
sudo microk8s.helm3 repo add nats https://nats-io.github.io/k8s/helm/charts/
sudo microk8s.helm3 repo update
sudo microk8s.kubectl create namespace nats
sleep 3
sudo microk8s.helm3 install nats nats/nats --namespace nats --wait --timeout=150s
while [ $? -ne 0 ]; do sudo microk8s.helm3 upgrade nats --install nats/nats --namespace nats --wait --timeout=150s; done

# Install Parse
git clone https://github.com/parse-community/parse-server
cd parse-server
sudo docker build --tag parse-server:local .
sudo docker save parse-server:local > parse-server.tar
sudo microk8s ctr image import parse-server.tar
sudo microk8s.kubectl create namespace parse
sudo microk8s.helm3 install parse /vagrant/parse-0.1.0.tgz --namespace parse
sleep 3
while [ $? -ne 0 ]; do sudo microk8s.helm3 upgrade parse --install /vagrant/parse-0.1.0.tgz --namespace parse; done
sleep 3
sudo microk8s.kubectl -n parse rollout status -w deployment/parse-deployment
sudo microk8s.kubectl -n parse rollout status -w deployment/mongodb

sudo microk8s.kubectl get pods --all-namespaces