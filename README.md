# K3S the sane way

![k3s-sane](./asset/k3s.png)

## But Why?

- The cost

Before I started this project, I had PlanetScale Scaler Pro, Vercel Teams, Fly.io, Railway...One night I realised the bills from Vercel alone was higher than my monthly grocery budget!!!

- Latency

Let's say if I am making a web app for my own convenience, I might buy a server in the UK, and deploy both the app and database on the same server, it will load instantly for me, and the data traveling between server and database would be short.

But how about my friends in the US? In Asia? In Australia? I soon bought a server in Singapore to test it.

[Why slow?](http://www.stuartcheshire.org/rants/latency.html) It took me close to 38.2 seconds to wait for data to come back after I clicked on login. The speed test was run under a [full stack Golang project (the worse stack for frontend, amazing tool for backend, I won't say twice)](https://github.com/zmzlois/LinkGoGo), all server render, no hydration. This means the page will be blank until the data comes in unless I build separate handlers for specific components that need data.

If I find a service provider that gives me this level of latency, I am out (unless they are very pretty 👉🏻👈🏻).

- Inspiration

I took inspiration from [Jeff Geerling's Raspberry Pi Cluster Project](https://www.jeffgeerling.com/blog/2020/raspberry-pi-cluster-episode-1-introduction-clusters) - if your stack can run under extreme conditions like the Rasberry Pi (ARM with 1GB RAM), you are golden. And you will learn a lot from running things on bare metal.

If we stop thinking about I need the OS of our generation to handle the complexity and separation of servers.

**I know what I want. I can't afford EKS by myself. I want a deployment strategy that's optimised no matter how extreme the condition is. I can't guarantee `the experience on the edge` with milliseconds of cold start-- the best I can do is a server close enough to my friends and the shortest distance between server and database.**

Let the fiber handle the rest. I pray.

#### What I want at the end...

- [Round-robin DNS](https://en.wikipedia.org/wiki/Round-robin_DNS): based on the requested user's location I route them to a server that's closest to them.
- [Database replication](): I don't want to only have one database. I want every server to have a replica of the same database. Each server might have multiple databases for different applications.

I bought 4 servers from a cloud provider around the world: London, Frankfurt, Seattle and Singapore. It's not the managed services from GKE or EKS that help you manage your Kubernetes cluster -- the only thing that came with them was the fact that they were booted with Debian 12.

## What's included

Currently:

- Prometheus & Grafana deshboard
- Traefik

Todo:

- Github Runner
-

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

//FIXME: Check how to attach nodes (node tolerence ) and make sure this thing is on the same node as the master via value? Girl you can't have database and application one in seattle and one in frankfurt.

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
