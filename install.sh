#!/usr/bin/env bash
set -eu

TARGET_NAMESPACE=ci-openshift-pipelines
K="kubectl -n ${TARGET_NAMESPACE}"
GITHUB_TOKEN="$(git config --get github.oauth-token)"

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

${K} get secret github-secret >/dev/null 2>/dev/null || {
    echo -e "------ \e[96mCreating GitHUB Secret}\e[0m"
    oc create secret generic github-secret --from-literal secretToken="${GITHUB_TOKEN}"
}

for task in buildah/buildah;do
            curl -Ls -f https://raw.githubusercontent.com/tektoncd/catalog/master/${task}.yaml | ${K} apply -f -
done

oc adm policy add-scc-to-user privileged -z ci-openshift-triggers-sa
for role in image-builder deployer;do
    oc policy add-role-to-user system:${role} -z ci-openshift-triggers-sa
done

for file in templates/triggers.yaml templates/pipeline-preview-url.yaml;do
    kubectl delete -f  ${file} 2>/dev/null || true
    kubectl create -f ${file}
done

oc get route el-preview-url 2>/dev/null >/dev/null || {
    oc expose service el-preview-url && oc apply -f <(oc get route el-preview-url  -o json |jq -r '.spec |= . + {tls: {"insecureEdgeTerminationPolicy": "Redirect", "termination": "edge"}}')
}

echo "Webhook Endpoint available at: https://$(oc get route el-preview-url -o jsonpath='{.spec.host}')"
