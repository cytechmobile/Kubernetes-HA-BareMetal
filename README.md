= Kubernetes HA @ Bare Metal
:toc:

An HA deployment of Kubernetes on Bare Metal. #noCloud

This document describes how to set up a Kubernetes cluster on Bare Metal (or dedicated servers, or EC2 instances, etc.) without making any assumptions about running on a cloud and making use of any special cloud features that would usually make your life easier (e.g. ELB) -- but at the same time lock you in with a cloud vendor! 


== Install Operating System: Ubuntu 16.04 

For setting up bare metal servers, please follow: [this guide]
[On a cloud, you would select an `ubuntu 16.04` image.] 


== Install Kubernetes Cluster [Requirements]

The approach we will use for setting up the Kubernetes cluster is based on the https://github.com/kubernetes-incubator/kubespray/[kubernetes-incubator/kubespray] project, with a couple of differentiations.  

First of all, let's take care of the `kubespray` requirements. 

As explained in the https://github.com/kubernetes-incubator/kubespray#requirements[kubespray requirements] doc, you need to set up a couple of things before asking `kubespray` to set up your k8s cluster. 

1. Install ansible on the machine that you will be using to initiate the installation. This is probably your workstation. (On macOS, installation is as simple as `brew install ansible`).

1. Having already installed the OS and having ssh access to the servers, we'll copy our public key to each of the target servers, for easier access: 

[bash]
----
cat ~/.ssh/<your_key>.pub
#copy this value
ssh root@<node>
mkdir .ssh
vi .ssh/authorized_keys
# paste the public key

#Now ensure we have enabled use of authorized_keys file 
vi /etc/ssh/sshd_config
#uncomment the line for Authorized keys
sudo service ssh restart
----

3. Enable IP forwarding

Follow instructions in http://www.ducea.com/2006/08/01/how-to-enable-ip-forwarding-in-linux/[the this article] to check if it's enabled and how to do so. 

4. Install Python 

Ensure you have python installed on each target node, so: `sudo apt install python`


== Install Kubernetes Cluster 

Now it's time to proceed with the installation of the actual cluster. 

In order to do this, we'll use `kubespray's` ansible playbooks, which involves two steps: 
1. Telling Ansible where the playbooks will run (in Ansible terms this is called "creating the inventory") 
2. Editing some options for the playbooks

=== Create inventory for ansible playbooks

This can be created using a python script (you might need to install `python3` -- `brew install python3`), by running the following set of commands, available in the https://github.com/kubernetes-incubator/kubespray/blob/master/docs/getting-started.md#building-your-own-inventory[kubespray guide for building your own inventory].

=== Logging using Elasticsearch, Fluentd, Kibana (EFK)

If you want to direct logs to an elasticsearch cluster, there is a simple option in kubespray to enable this - WHICH I AM NOT USING. You're supposed to edit file: `my_inventory/group_vars/k8s-cluster.yml` and find the `efk_enabled` attribute, making sure it is set to true.

However, I found a couple of things I didn't like with this approach: 
1. elasticsearch and kibana versions used are still too old (2.4.x)
1. they're deployed in the `kube-system` namespace. I'd like them in their separate namespace. 
1. `kibana` is deployed with a `KIBANA_BASE_URL` attribute, so it can be served using `kubectl proxy`, but I don't want it limited that way. 

In search of a better solution, I found this https://github.com/gregbkr/kubernetes-kargo-logging-monitoring.git[very interesting guide], however I was not able to deploy the `Logging` solution, due to an issue with the persistent volume.  

----
# Monitoring apps for k8s
efk_enabled: true
----

Now, you can rerun the playbook. 

After playbook has finished, you need to manually change a couple of things. 

1. Edit the Kibana deployment, and **remove** the `KIBANA_BASE_URL` attribute. 
1. Edit the Kibana service, changing the type from `ClusterIP` to `NodePort`, so you can access it from outside the cluster. Also 

----
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: kube-system
spec:
  type: NodePort
  selector:
    k8s-app: kibana-logging
  ports:
  - port: 5601
    nodePort: 30601
----

1. You should now be able to access k8s_node_ip:30601

= Set up GlusterFS cluster

=== Create LVs

Create a logical volume with 100GB to each server with the following command: ﻿`sudo lvcreate -L 100g <name-of the-volume-group>`
The name of the volume group can be retrieved with the following command under VG column: `sudo lvs`

=== Add GlusterFS to inventory

Add the volume disk id, on the same line, for each host in your glusterfs cluster inventory: 
e.g. `disk_volume_device_1=/dev/mapper/ent--vg-lvol0`. 

Sample inventory: 
----
[all]
pegasus      ansible_host=139.91.23.5 ip=139.91.23.5 disk_volume_device_1=/dev/mapper/pegasus--vg-lvol0
ent      ansible_host=139.91.23.8 ip=139.91.23.8 disk_volume_device_1=/dev/mapper/ent--vg-lvol0
----
