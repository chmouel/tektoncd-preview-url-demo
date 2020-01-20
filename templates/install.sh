#!/usr/bin/env bash
set -eu

TARGET_NAMESPACE=ci-openshift-pipelines

K="kubectl -n ${TARGET_NAMESPACE}"

config_params() {
    if [[ -d $1 ]];then
        files=(${1}/*.yaml)
    else
        files=($1)
    fi

}


oc project ${TARGET_NAMESPACE} 2>/dev/null >/dev/null || {
    echo -e "------ \e[96mCreating Project: ${TARGET_NAMESPACE}\e[0m"
	oc new-project ${TARGET_NAMESPACE} >/dev/null
}


for file in *.yaml;do
    kubectl delete -f  ${file} 2>/dev/null || true
    kubectl create -f ${file}
done

