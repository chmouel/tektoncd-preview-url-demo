#!/usr/bin/env bash
set -eu

TARGET_NAMESPACE=tekton-demo
K="kubectl -n ${TARGET_NAMESPACE}"
O="oc -n ${TARGET_NAMESPACE}"
GITHUB_TOKEN="$(git config --get github.oauth-token)"

config_params() {
    if [[ -d $1 ]];then
        files=(${1}/*.yaml)
    else
        files=($1)
    fi

}


# Create Project where we are going to work on
oc project ${TARGET_NAMESPACE} 2>/dev/null >/dev/null || {
	oc new-project ${TARGET_NAMESPACE} >/dev/null
}

# Create Github Secret
${K} get secret github-secret >/dev/null 2>/dev/null || {
    ${K} create secret generic github-secret --from-literal secretToken="${GITHUB_TOKEN}"
}

# General configuration
${K} get configmap demo-config >/dev/null 2>/dev/null || {
    ${K} create configmap demo-config \
         --from-literal=webconsole-url="https://$(oc get route -n openshift-console console -o jsonpath='{.spec.host}')"
}

for task in buildah/buildah;do
            curl -Ls -f https://raw.githubusercontent.com/tektoncd/catalog/master/${task}.yaml | ${K} apply -f -
done

oc adm policy add-scc-to-user privileged -z tekton-demo-triggers-sa
for role in image-builder deployer;do
    oc policy add-role-to-user system:${role} -z tekton-demo-triggers-sa
done

for file in templates/triggers.yaml templates/pipeline-preview-url.yaml;do
    ${K} delete -f  ${file} 2>/dev/null || true
    ${K} create -f ${file}
done


${O} get route el-preview-url 2>/dev/null >/dev/null || {
    ${O} expose service el-preview-url && oc apply -f <(${O} get route el-preview-url  -o json |jq -r '.spec |= . + {tls: {"insecureEdgeTerminationPolicy": "Redirect", "termination": "edge"}}')
}

echo "Webhook Endpoint available at: https://$(${O} get route el-preview-url -o jsonpath='{.spec.host}')"
