# openshift4-debug
An unofficial series of tools that enable various debugging utilities for Red Hat OpenShift Container Platform 4.

> **Please note nothing in this repository is connected to or supported by [Red Hat](https://redhat.com) in any way.**

> **If you are experiencing issues with your [Red Hat OpenShift Container Platform 4](https://www.redhat.com/en/openshift-4) cluster and have a valid support subscription, it is ALWAYS best to first reach out to [Red Hat Support](https://access.redhat.com/support/) directly.**

> **Running any external software on your Red Hat products runs the risk of downtime in production, data loss, or security breach, including what is found within this repository.**

> **No responsibility is taken by any of the parties involved with this repository for issues arising with your business or systems as a result of utilizing anything or taking the advice of anything in this repository.**

> **USE AT YOUR OWN RISK.**

# Usage
Provided in this repository is a collection of scripts and YAML files which you can deploy to your [Red Hat OpenShift Container Platform 4](https://www.redhat.com/en/openshift-4) cluster in attempts to enable deeper debugging, logging, or a feature that perhaps does not currently exist in a current Red Hat offering at this time.

The repository is divded into two sections; setting up the debugging project and required components, and then utilizing various utilities within this repository to enable the desired functionality.  It is expected that you will first set up the `openshift4-debug` project and environment prior to running any available utilities, as utilities are authored expecting to be placed into the `openshift4-debug` project.  Below, you will find instructions on setting up the initial project.

## Setting up the `openshift4-debug` Project
Ensure you are logged into your [Red Hat OpenShift Container Platform 4](https://www.redhat.com/en/openshift-4) cluster as a user with expansive admin privileges, such as `system:admin` with the [oc](https://developers.redhat.com/openshift/command-line-tools) OpenShift command line utility.

```bash
$ oc create -f openshift4-debug.yaml
namespace/openshift4-debug created
serviceaccount/openshift4-debug created
securitycontextconstraints.security.openshift.io/openshift4-debug created
imagestream.image.openshift.io/openshift4-debug created
```

This creates a number of items within your cluster, notably a namespace, a service account, a security context constraint, and an image stream.  The namespace should encompass all entities from the `openshift4-debug` repository including users, images, and utilities deployed.  The service account and security context restraint are a carte blanche access to the cluster by this user, including the node's root filesystems.  Some utilities that monitor node performance require this.

> **It is a major security concern to have an account running pods with as much access as the security context in this repository provides, and this can cause downtime, corruption of data, or unintended access to the cluster.  Please be careful and use at your own risk.**

From there, read on how to apply utilities to your `openshift4-debug` project within your cluster.

## Utilities
Utilities may vary greatly in behavior and setup, and instructions for configuration are provided by the respective utility.  Select a utility below to learn more and see how to deploy it to your `openshift4-debug` project on your cluster.

## Cleaning Up
When `openshift4-debug` has outlived it's usefulness, remove it entirely from the cluster like so:

```bash
# Remove all running utilities
$ oc delete all -l=app=openshift4-debug

# Delete the serviceAccount
$ oc delete sa openshift4-debug

# Delete the securityContextConstraint
$ oc delete scc openshift4-debug

# Delete the namespace
$ oc delete ns openshift4-debug
```

# Contributing
Contributions are welcome and those who chose to contribute are thanked immensely.

Please follow the instructions in our [Contributions Guide](CONTRIBUTING.md) to get started.

# License
*Apache V2 License*
Copyright [2021] [Robb Manes]

Licensed under the apache license, version 2.0 (the "license");
You may not use this file except in compliance with the license.
You may obtain a copy of the license at

[http://www.apache.org/licenses/license-2.0](http://www.apache.org/licenses/license-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the license is distributed on an "as is" basis,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

See the license for the specific language governing permissions and
limitations under the license.

The full Apache V2 License is available within this repository in the [LICENSE.md][LICENSE.md] file.
