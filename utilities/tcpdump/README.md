# tcpdump
The tcpdump utility allows you to perform automated packet captures directly on nodes.

The script that makes up this `daemonSet` has intentionally been authored to produce a seperate capture for each individual interface on the node, so as to make analysis easier and not conflict capture of packets when options such as `-i any` are used with tcpdump.

This utility can be deployed to your [Red Hat OpenShift Container Platform 4](https://www.redhat.com/en/openshift-4) cluster to run tcpdumps directly on the nodes.

Before performing any of the below steps, ensure you are within the `openshift4-debug` project.
```bash
$ oc project openshift4-debug
Now using project "openshift4-debug" on server "https://api.example.com:6443".
```

## Deployment
This utility has minimal prerequisites as it does not require an image build, instead relying on the Red Hat provided `toolbox` container, which is based off of `registry.redhat.io/rhel8/support-tools`.

First, add the `tcpdump-entrypoint.sh` as a `configMap` from within this directory.
```bash
$ oc create configmap tcpdump-entrypoint --from-file=tcpdump-entrypoint.sh                 
configmap/tcpdump-entrypoint created
```

You may now launch the `daemonSet`:
```bash
$ oc create -f daemonset.yaml
```

Verify the `daemonSet` loaded correctly:
```bash
$ oc get ds
NAME        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR    AGE
tcpdump     0         0         0       0            0           tcpdump=true     4s
```

Finally, label the nodes you wish the `daemonSet` to execute on.
```bash
$ oc get nodes
NAME                   STATUS   ROLES    AGE    VERSION
master-0.example.com   Ready    master   4d3h   v1.19.0+7070803
worker-0.example.com   Ready    worker   4d3h   v1.19.0+7070803
worker-1.example.com   Ready    worker   4d3h   v1.19.0+7070803

$ oc label node worker-1.example.com tcpdump=true
node/worker-1.example.com labeled
```

When the node is labeled, you should be able to see the pod start, and capture on the appropriate devices:
```bash
$ oc get pods 
NAME              READY   STATUS             RESTARTS   AGE
tcpdump-8rk6n     1/1     Running            1          2m32s

$ oc logs tcpdump-8rk6n
Executing tcpdump utility on worker-1.example.com...
Found the following interfaces:
br0 ens3 lo ovs-system tun0 veth00af418f veth03b837e4 veth2f6711b7 veth38b1ce54 veth484afab3 veth4e53a9da veth6ab36bfb veth94a678f6 vethd66e2b04 vethe4e4e845 vetheb6a8fd2 vxlan_sys_4789
Executing tcpdump -s 0 -i br0 -C 1000 -Z root -w //var/log/tcpdump/tcpdump-worker-1.example.com.pcap
Executing tcpdump -s 0 -i ens3 -C 1000 -Z root -w //var/log/tcpdump/tcpdump-worker-1.example.com-ens3-20210126174505.pcap
- - - - 8< - - - -
```

Files are output, by default, to the host's `/var/lib/tcpdump` directory and rotated out every 1 gigabyte.