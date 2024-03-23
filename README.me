# K3S multi-node deployment

# What's included 
- Prometheus & Grafana deshboard
- Traefik


## Provisioning


### Step 1
To provision all servers 
```bash 
ansible-playbook playbook/site.yml
```


To reset all servers 

```bash 
ansible-playbook playbook/reboot.yml
```

After k3s is installed on the master run: 

```bash
ssh root@<master-ip>:~/.kube/config ~/.kube/config-ctb-london
```

Edit the `~/.kube/config-ctb-london` server address to the master node's address

And then set it as environment variable as: 
```bash
export KUBECONFIG=~/.kube/config-ctb-london
```

### Step 2 
Helm charts configuration 
1. Run 
```bash 
ansible-playbook helm/prereq.yml  
```
to ensure helm is released and if 

2. Install Prometheus and Grafana stack 

Run 
```bash 
ansible-playbook helm/prometheus/install.yml -vvv
```
:::tips 
use `-vvv` for VERY VERBOSE DEBUG MODE
:::

Check it health by running 

```bash 
kubectl --namespace monitoring get pods
```
Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

 # FIXME: Check how to attach nodes (node tolerence ) and make sure this thing is on the same node as the master via value? Girl you can't have database and application one in seattle and one in frankfurt.


After installing Prometheus and Grafana do this:

Remember to install openlens on local computer to monitor the cluster by 
```bash 
brew install openlens
```
After installing openlens remember to add a plugin on openlens `@alebcay/openlens-node-pod-menu` 

OpenLens will allow you to enter a pod's and monitor their health without getting cancer. Be careful of what the plugin can do it might terminate a pod. 


#### Notes to self
Branch main: using shell script to deploy k3s with bare metal

Branch k3s-cluster: using ansible to bring a complete solution for a bare metal machine 

Branch k8s-cluster: using shell script to deploy k8s
