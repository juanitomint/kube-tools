# kubetools.sh

A compilation of useful functions for working with kubernetes

## Overview

In the heat of the battle we need to be fast so for keep things going here are some principles
* kiss Keep it simple! righT?
* provide visual aid preferable using fuzzy finder fzf command
* echo the command you're executing others can learn and re-use
* use https://github.com/reconquest/shdoc to build this README.md
````bash
shdoc kubetools.sh >README.md
````
#### INSTALL

Add this file to your .profile .bashrc .zshrc
```bash
...
source $PATH_TO_FILE/kubetools.sh
...
````

## Index

* [kpo()](#kpo)
* [ke()](#ke)
* [kno()](#kno)
* [kdp()](#kdp)
* [kd()](#kd)
* [kg()](#kg)
* [kppn()](#kppn)
* [kppnn()](#kppnn)
* [knaws()](#knaws)
* [knawsall()](#knawsall)
* [kds()](#kds)
* [kss()](#kss)
* [kst()](#kst)
* [ksta()](#ksta)
* [kfmds()](#kfmds)
* [krun()](#krun)
* [krunbrowse()](#krunbrowse)
* [knew()](#knew)
* [kproxy()](#kproxy)

### kpo()

a shortcut for: get pods

#### Example

```bash
$ kpo -o wide
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* a list of pods

### ke()

a shortcut for: get events timestamp sorted

#### Example

```bash
$ ke
```

#### Arguments

* **...** (all): the options you want ie: -l wide

#### Output on stdout

* a list of events

### kno()

a shortcut for: get nodes

#### Example

```bash
$ kno -o wide -l kafka-connect-dedicated=trues
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* a list of nodes

### kdp()

a shortcut for: get deployments

#### Example

```bash
$ kdp -o wide
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* a list of deployments

### kd()

a shortcut for: describe 

#### Example

```bash
$ kd deployment -l app=kafka
```

#### Arguments

* **...** (all): the options you want ie: deployments

#### Output on stdout

* a list of yaml

### kg()

a shortcut for: get 

#### Example

```bash
$ kg pods -l app=kafka
```

#### Arguments

* **...** (all): the options you want ie: pods

#### Output on stdout

* a list of resources or a single resource

### kppn()

list all the pods in a node picking one node or passing the node name as an argument

#### Example

```bash
$ kppn ip-172-18-4-100.ap-northeast-1.compute.internal
$ kppn
```

#### Arguments

* # @arg

#### Output on stdout

* list of pods

### kppnn()

list all the pods in a node picking one pod from the current namespace

#### Example

```bash
$ kppnn
```

#### Arguments

* # @arg

#### Output on stdout

* list of pods

### knaws()

get nodename given your aws ids

#### Example

```bash
$ knaws i-044cb8a4d984cba35
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* ip-172-18-6-113.ap-northeast-1.compute.internal - aws:///ap-northeast-1d/i-402kr4t2j546hvy23

### knawsall()

get all aws ids from your nodes

#### Example

```bash
$ knawsall
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* ip-172-18-6-113.ap-northeast-1.compute.internal - aws:///ap-northeast-1d/i-402kr4t2j546hvy23

### kds()

a shortcut for: get daemonsets

#### Example

```bash
$ kds -o wide
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* a list of daemonsets

### kss()

a shortcut for: get statefulsets

#### Example

```bash
$ kss -o wide
```

#### Arguments

* **...** (all): the options you want ie: -o wide

#### Output on stdout

* a list of statefulsets

### kst()

Get a  status count from the current namespace

#### Example

```bash
$ kst
```

#### Arguments

* **...** (all): the options you want

#### Output on stdout

* pod status 5 Completed 5 CrashLoopBackOff 38 Running

### ksta()

Get a  status count from all namespaces

#### Example

```bash
$ ksta
```

#### Arguments

* **...** (all): the options you want

#### Output on stdout

* pod status 5 Completed 5 CrashLoopBackOff 38 Running

### kfmds()

find missing daemonsets pods

#### Example

```bash
$ kfmds filebeatlogz-filebeat
```

#### Arguments

* **$1** (name): od the daemonset
* **...** (all): the options you want

#### Output on stdout

* Node ip-172-27-2-72.ec2.internal is not running a pod from the daemonset filebeatlogz-filebeat

### krun()

Run an epheremal pod with the image you want

#### Example

```bash
$  krun python:3-slim bash --env=VAR1=value1 --env=VAR2=value2 --port=8080
```

#### Arguments

* **$1** (imagename):
* **$2** (command):

#### Output on stdout

*  run an ephemeral pod

### krunbrowse()

Run an epheremal pod with the image you want browsing from local docker images

#### Example

```bash
$  krunbrowse
```

### knew()

Run an isolated kubernetes context using kubie

#### Example

```bash
$  knew
```

### kproxy()

Run an epheremal pod to proxy to internal aws host

#### Example

```bash
$  kproxy kproxy ads-monetization-airflow-database.cluster-crevvby4h2ik.us-east-1.rds.amazonaws.com	 5432
```

#### Arguments

* **$1** (hostname):
* **$2** (port):

#### Output on stdout

*  run tcp-proxy

