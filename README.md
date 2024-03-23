# K3S multi-node deployment

# What's included

- [Prometheus](https://prometheus.io/) & [Grafana dashboard](https://grafana.com/): we install it via the community version [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml) it will come with every necessity baked in.
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

to ensure helm is installed and if it is the latest version.

2. Install Prometheus and Grafana stack

In the [prometheus install playbook](./helm/prometheus/install.yml), using ansible's built-in helm module to install helm chart. To have all the pods deploy to the same node, the easiest way is via a node selector. So I went through the [prometheus stack chart](./helm/prometheus/chart.yml) to find all the pods that has `nodeSelector` attached and update the value to the deploy node label. I found the label in openlens' metadata for nodes.

To learn more about the relationship between nodes, pods, and their relationships, look at [taint and toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#:~:text=Tolerations%20allow%20the%20scheduler%20to,not%20scheduled%20onto%20inappropriate%20nodes.) and [node affinity - assigning pods to nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) on kubernetes documentation.

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

//FIXME: Check how to attach nodes (node tolerence ) and make sure this thing is on the same node as the master via value? Girl you can't have database and application one in seattle and one in frankfurt.

After installing Prometheus and Grafana do this:

Remember to install openlens on local computer to monitor the cluster by

```bash
brew install openlens
```

After installing openlens remember to add a plugin on openlens `@alebcay/openlens-node-pod-menu`

OpenLens will allow you to enter a pod's and monitor their health without getting cancer. Be careful of what the plugin can do it might terminate a pod.

For services that are deployed to kubernetes, without active deployment you can access their dashboard via port forwarding on openlens.

**Available dashboard**

- Prometheus alert manager
- Grafana

#### Notes to self

Branch main: using shell script to deploy k3s with bare metal

Branch k3s-cluster: using ansible to bring a complete solution for a bare metal machine

Branch k8s-cluster: using shell script to deploy k8s
