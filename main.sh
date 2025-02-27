#!/bin/bash -e


if [ $# -ne 3 ]
then
    echo $#
    echo "The script needs 3 arguments <kubeconfig_path> <deployment yaml path> <keda hpa yaml path>"
    echo "ex:- ./main.sh <kubeconfig_path> <deployment yaml path> <keda hpa yaml path>"
    exit 1
fi


connect()
{   
    echo -e "================ \n info: current cluster: -$KUBECONFIG "
    if kubectl get nodes
    then
        echo -e "================ \n info: connected to the given k8s cluster "
        
    else
        echo "Error: Not able to connect to the cluster, exiting"
        exit 1
    fi
}

install_tools()
{
    if helm version &> /dev/null
    then
        echo -e "================ \n info: helm is installed \n===="
    else
        echo "helm not found installing it...."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh
        rm get_helm.sh
        echo -e "================ \n info: helm installion complete... Moving Ahead "
    fi
    if kubectl get pods -n keda | grep -i operator &> /dev/null
    then    
        echo "Keda installation verified.."
    else 
        echo -e "================ \n info: Installing KEDA... "
        helm repo add kedacore https://kedacore.github.io/charts
        helm repo update
        helm install keda kedacore/keda --namespace keda --create-namespace
        echo -e "================ \n info: KEDA installation complete.. "
        if !kubectl get pods -n keda | grep -i operator &> /dev/null
        then    
            echo "Error: unable to install Keda, exiting the script"
            exit 1
        fi
    fi
}

create_resource()
{
    export KUBECONFIG=$1
    kubectl apply -f $2 -f $3
    #kubectl apply -f nginx-dep.yaml -f nginx-kafka-keda.yaml -f #nginx-hpa.yaml
    echo -e "================ \n info: waiting for 30 sec for the deployment to be complete "
    sleep 30
}

get_status()
{   
    echo -e "================ \n info: checking if the deployment went success:- "
    count=0
    while true
    do
        if [ $count -eq 5 ]
        then    
            echo -e "================ \n info:Error: waited for more than 25 seconds, exiting "
            exit 1
        fi
        READY_STATUS=$(kubectl get deployment/nginx-deployment -n app-ns -o jsonpath='{.status.readyReplicas}/{.status.replicas}')
        if [[ "$READY_STATUS" == "$(kubectl get deployment/nginx-deployment -n app-ns -o jsonpath='{.status.replicas}')/$(kubectl get deployment/nginx-deployment -n app-ns -o jsonpath='{.status.replicas}')" ]]
        then
            kubectl get svc/nginx-service -n app-ns | tail -1 | awk '{print "The service can be accessed on this address:- "$3":30001"}'
            echo -e "================ \n info: Number of replicas for the deployment is :- $({kubectl get deployment/nginx-deployment -n app-ns -o jsonpath='{.spec.replicas}'})"
            echo -e "================ \n info: CPU/Mem utilization of the pods are:-  :"
            kubectl top pods -n app-ns | grep -i nginx
            
        else
            echo "deployment not healthy yet, sleeping for 5 more seconds"
            sleep 5
        fi
        count=$((count + 1))
    done
}
export KUBECONFIG=$1
connect
install_tools
create_resource "$1" "$2" "$3"
get_status