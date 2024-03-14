#!/bin/bash
# @file kubetools.sh
# @brief A compilation of useful functions for working with kubernetes
# @description
#     In the heat of the battle we need to be fast so for keep things going here are some principles
#      * kiss Keep it simple! righT?
#      * provide visual aid preferable using fuzzy finder fzf command
#      * echo the command you're executing others can learn and re-use
#      * use https://github.com/reconquest/shdoc to build this README.md
#````bash
#shdoc kubetools.sh >README.md
#````
# #### INSTALL
#
# Add this file to your .profile .bashrc .zshrc
# ```bash
# ...
#  source $PATH_TO_FILE/kubetools.sh
# ...
# ````

COMMAND="kubectl"
if command -v kubecolor &>/dev/null; then
    COMMAND=kubecolor
    alias kubectl=$COMMAND
fi

# @description a shortcut for: get pods
# @arg $@ all the options you want ie: -o wide
# @stdout a list of pods
# @example
#   $ kpo -o wide
kpo() {
    echo "kubectl get pods $@"
    $COMMAND get pods $@

}

# @description a shortcut for: get events timestamp sorted
# @arg $@ all the options you want ie: -l wide
# @stdout a list of events
# @example
#   $ ke
ke() {
    echo "kubectl get events --sort-by='.metadata.creationTimestamp' $@"
    $COMMAND get events --sort-by='.metadata.creationTimestamp'

}

# @description a shortcut for: get nodes
# @arg $@ all the options you want ie: -o wide
# @stdout a list of nodes
# @example
#   $ kno -o wide -l kafka-connect-dedicated=trues
kno() {
    echo "kubectl get nodes $@"
    NODE=$(kubectl get nodes $@ | fzf | awk '{ print $1}')
    echo "kubectl describe node $NODE"
    $COMMAND describe node $NODE | tee | less
}
# @description a shortcut for: get deployments
# @arg $@ all the options you want ie: -o wide
# @stdout a list of deployments
# @example
#   $ kdp -o wide
kdp() {
    echo "kubectl get deployments $@"
    $COMMAND get deployments $@
}

# @description a shortcut for: describe 
# @arg $@ all the options you want ie: deployments
# @stdout a list of yaml
# @example
#   $ kd deployment -l app=kafka
kd() {
    echo "kubectl describe $@"
    $COMMAND describe $@
}

# @description a shortcut for: get 
# @arg $@ all the options you want ie: pods
# @stdout a list of resources or a single resource
# @example
#   $ kg pods -l app=kafka
kg() {
    echo "kubectl get $@"
    $COMMAND get $@
}

# @description list all the pods in a node picking one node or passing the node name as an argument
# @arg
# @stdout list of pods
# @example
#   $ kppn ip-172-18-4-100.ap-northeast-1.compute.internal
#   $ kppn
kppn() {
    if [ -z "$1" ]; then
        NODE=$(kubectl get nodes --no-headers | fzf | awk '{ print $1}')
    else
        NODE="$1"
    fi
    echo "kubectl get pods -A --field-selector  spec.nodeName=$NODE"
    $COMMAND get pods -A --field-selector spec.nodeName=$NODE
}

# @description list all the pods in a node picking one pod from the current namespace
# @arg
# @stdout list of pods
# @example
#   $ kppnn
kppnn() {

    POD=$(kubectl get pods -o wide | fzf | awk '{print $1}')
    NODE=$(kubectl get pod $POD -o json | jq -r ".spec.nodeName")
    echo "kubectl get pods -A --field-selector  spec.nodeName=$NODE $@"
    $COMMAND get pods -A --field-selector spec.nodeName=$NODE $@
}

# @description get nodename given your aws ids
# @arg $@ all the options you want ie: -o wide
# @stdout ip-172-18-6-113.ap-northeast-1.compute.internal - aws:///ap-northeast-1d/i-402kr4t2j546hvy23
# @example
#   $ knaws i-044cb8a4d984cba35
knaws() {
    echo "kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name} - {@.spec.providerID}{\"\n\"}' | grep $1"
    if [ -z "$1" ]; then
        echo "provide an aws host id like: i-57gwjie18816b53k0"
        echo "knaws i-57gwjie18816b53k0"
    else
        $COMMAND get nodes -o jsonpath='{range .items[*]}{@.metadata.name} - {@.spec.providerID}{"\n"}' | grep $1
    fi
}

# @description get all aws ids from your nodes
# @arg $@ all the options you want ie: -o wide
# @stdout ip-172-18-6-113.ap-northeast-1.compute.internal - aws:///ap-northeast-1d/i-402kr4t2j546hvy23
# @example
#   $ knawsall
knawsall() {
    echo "kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name} - {@.spec.providerID}{\"\n\"}'"
    $COMMAND get nodes -o jsonpath='{range .items[*]}{@.metadata.name} - {@.spec.providerID}{"\n"}'
}
# @description a shortcut for: get daemonsets
# @arg $@ all the options you want ie: -o wide
# @stdout a list of daemonsets
# @example
#   $ kds -o wide
kds() {
    echo "kubectl get daemonsets $@"
    $COMMAND get daemonsets $@
}

# @description a shortcut for: get statefulsets
# @arg $@ all the options you want ie: -o wide
# @stdout a list of statefulsets
# @example
#   $ kss -o wide
kss() {
    echo "kubectl get statefulsets $@"
    $COMMAND get statefulsets $@
}

# @description Get a  status count from the current namespace
# @arg $@ all the options you want
# @stdout pod status 5 Completed 5 CrashLoopBackOff 38 Running
# @example
#   $ kst
kst() {
    echo "pod status"
    $COMMAND get pods --no-headers $@ | awk '{ print $3}' | sort | uniq -c
}

# @description Get a  status count from all namespaces
# @arg $@ all the options you want
# @stdout pod status 5 Completed 5 CrashLoopBackOff 38 Running
# @example
#   $ ksta
ksta() {
    echo "pod status all"
    k get pods -A --no-headers $@ | awk '{ print $4}' | sort | uniq -c
}

# @description find missing daemonsets pods
# @arg $1 name od the daemonset
# @arg $@ all the options you want
# @stdout Node ip-172-27-2-72.ec2.internal is not running a pod from the daemonset filebeatlogz-filebeat
# @example
#   $ kfmds filebeatlogz-filebeat
kfmds() {
    # Get the list of all nodes
    nodes=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

    # Specify the daemonset name
    daemonset_name="$1"

    # Iterate over each node
    for NODE in $nodes; do
        # Get the number of running pods from the daemonset on the current node
        running_pods=$(kubectl get pods --field-selector=status.phase=Running --field-selector=spec.nodeName=$NODE --selector='app='$daemonset_name -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}')

        # Check if there are no running pods from the daemonset on the current node
        if [[ -z $running_pods ]]; then
            echo "Node $NODE is not running a pod from the daemonset $daemonset_name"
        fi
    done
}
# @description Run an epheremal pod with the image you want
# @arg $1 imagename
# @arg $2 command
# @stdout  run an ephemeral pod
# image: python:3-slim
# command: bash
# ------------------------------
# extra arguments:
# --env=VAR1=value1
# --env=VAR2=value2
# --port=8080
# @example
#   $  krun python:3-slim bash --env=VAR1=value1 --env=VAR2=value2 --port=8080
krun() {
     if [ -z "$1" ] || [ -z "$2" ]; then
        echo "missing parameters..."
        echo "usage: krun <image> <command>"
        echo "examples"
        echo "simple: krun python:3-slim bash"
        echo "complete: krun python:3-slim bash --env=VAR1=value1 --env=VAR2=value2 --port=8080 "
        return 1
     fi
    # generate a random string
    randomstr=$(echo $RANDOM | md5sum | head -c 4)
    echo "run an ephemeral pod"
    image="$1"
    command="$2"
    echo "image: $image"
    echo "command: $command"
    echo "pod name: ephemeral-$randomstr"
    echo "------------------------------"
    # remove $1 and $2 from $@
    shift 2
    echo "extra arguments:"
    for item in "$@" ; do
        echo $item
    done
    $COMMAND run ephemeral-$randomstr --rm --image=$image --labels=${LABELS} -it $@ -- $command
}

# @description Run an epheremal pod with the image you want browsing from local docker images
# If you have a file called .docker-images in your home directory it will use that
# @example
#   $  krunbrowse
krunbrowse() {
    if [ -f ~/.docker-images ]; then
        image=$(cat ~/.docker-images|fzf )
    else 
        image=$(docker images|awk '{ print $1":"$2 }'|fzf )
    fi
    command=$(echo -e "bash\nsh\nzsh"|fzf)
    # remove $1 from $@ arguments
    shift
    krun $image $command $@
}
# @description Run an isolated kubernetes context using kubie
# @example
#   $  knew
knew() {
if command -v kubie &>/dev/null; then
    kubie ctx
else 
    echo "kubie is not installed"
    echo "in order to have independent contexts you need to install kubie"
    echo "https://github.com/sbstp/kubie"
fi

}
# Function to execute on Ctrl+C
function handle_ctrl_c() {
    echo "Ctrl+C captured. Exiting..."
    # Add any cleanup code here
    exit 0
}

# @description Run an epheremal pod to proxy to internal aws host
# @arg $1 hostname
# @arg $2 port
# @stdout  run tcp-proxy
# image: python:3-slim
# command: bash
# ------------------------------
# extra arguments:
# --env=VAR1=value1
# --env=VAR2=value2
# --port=8080
# @example
#   $  kproxy kproxy ads-monetization-airflow-database.cluster-crevvby4h2ik.us-east-1.rds.amazonaws.com	 5432
kproxy () {
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "missing parameters..."
        echo "usage: kproxy <hostname> <remote_port> <local_port>"
        echo "examples"
        echo "simple: kproxy ads-monetization-airflow-database.cluster-crevvby4h2ik.us-east-1.rds.amazonaws.com	 5432"
        return 1
fi
randomstr=$(echo $RANDOM | md5sum | head -c 4)
echo "run tcp-proxy"
    hostname="$1"
    remote_port="$2"
    local_port="$3"
    echo "host: $hostname"
    echo "local port: $local_port"
    echo "remote port: $remote_port"
    echo "pod name: tcp-proxy-$randomstr"
    echo "------------------------------"



echo "finding ip for: ${1}"
kubectl run dnsutils-${randomstr} --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 -- sleep "infinity"
kubectl wait pods dnsutils-${randomstr} --for condition=Ready --timeout=45s
LABELS=source=kubetools.sh
REMOTE_IP=$(kubectl exec dnsutils-${randomstr} --labels=${LABELS} -- nslookup ${hostname} |grep Name -A1|tail -n1|grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
# set up the clean up on sigint
if [ $? -eq 0 ]; then
    echo "remote IP: ${REMOTE_IP}"
    kubectl run tcp-proxy-${randomstr} --env="REMOTE_IP=${REMOTE_IP}" --env="LOCAL_PORT=${remote_port}" --env="REMOTE_PORT=${remote_port}" --env="PROTOCOL=tcp" --image=henkelmax/proxy --labels=${LABELS}
    kubectl wait pods tcp-proxy-${randomstr} --for condition=Ready --timeout=45s
    echo "press ctrl+c to exit"
    kubectl port-forward tcp-proxy-$randomstr $local_port:$remote_port
    ( trap exit SIGINT ; echo 'clean up!';kubectl delete  pod/dnsutils-${randomstr} pod/tcp-proxy-${randomstr};echo "bye!")
else
    echo "IP Address for ${DB_HOST}: not found"
    kubectl delete  pod/dnsutils-${randomstr}
    return 1

fi
}
