#!/bin/bash

set -e

action=$1
cloud=$2
region=$3
run_path=$4

if [ -z "${TF_PARALLELISM}" ]; then
    TF_PARALLELISM=1
fi

function help() {
    echo "run.sh [Action] [Cloud] [Region] [Environment]"
    exit 1
}

if [ -z "$action" ]; then
    echo "Action is not provided"
    echo
    help
fi
if [ -z "$cloud" ]; then
    echo "Cloud is not provided"
    echo
    help
fi
if [ -z "$region" ]; then
    echo "Region is not provided"
    echo
    help
fi
if [ -z "${run_path}" ]; then
    echo "Run path is not provided"
    echo
    help
fi

run_path="${cloud}/${run_path}"


function run_dir() {
    local full_run_path=${1%/}

    # legacy support (s3, iam)
    if [ -f "${full_run_path}/main.tf" ]; then
        echo "${full_run_path}/main.tf file found, running legacy mode with ${var_file_path}..."
        run_legacy "${full_run_path}"
        return
    fi

    # enter each wave
    for p in $(ls -1 -d "${full_run_path}"/wave* 2>/dev/null); do
        run_dir "$p"
    done

    # find each
    for p in $(ls -1 "${full_run_path}"/*.tfvars 2>/dev/null); do
        if echo "$p" |grep -q '\.backend\.'; then continue; fi
        if echo "$p" |grep -q '\/shared\.tfvars'; then continue; fi
        run_file "${p%.tfvars}"
    done
}


function run_file() {
    local full_run_path="$1"
    local module_file="${full_run_path}.module"
    local variable_file="${full_run_path}.tfvars"
    local backend_file="${full_run_path}.backend.tfvars"
    local local_run_name=$(basename "${full_run_path}")
    local local_run_path=$(dirname "${full_run_path}")

    echo
    echo "Running ${action} on ${full_run_path}"
    echo

    if [ ! -f "${module_file}" ]; then
        echo "missing .module file"
        exit 1
    fi
    module=$(cat "${module_file}" 2>/dev/null)
    if [ -z "$module" ]; then
        echo "${module_file} file is empty"
        exit 1
    fi
    module_dir="modules/${module}"
    if [ ! -d "${module_dir}" ]; then
        echo "${module_dir} directory does not exist"
        exit 1
    fi
    if [ ! -f "${variable_file}" ]; then
        echo "missing .tfvars file"
        exit 1
    fi

    # if custom backend file exists, use it
    # if not, generate key and use the default
    if [ -f "${backend_file}" ]; then
        init_opts="-backend-config=${backend_file}"
    else
        # generate tfstate key without cloud name and wave name
        local tfstate_path=$(echo "${full_run_path}" |perl -p -e "s/${cloud}\///" |perl -p -e "s/wave.+\///")
        init_opts="-backend-config='key=${tfstate_path}.tfstate'"
    fi

    # find shared tfvars files
    local p="${local_run_path}"
    pushd . >/dev/null 2>&1
    for s in $(echo "$p" |tr \/ ' '); do
        cd $s
        if [ -f shared.tfvars ]; then
            apply_opts="${apply_opts} -var-file=$(pwd)/shared.tfvars"
        fi
    done
    popd >/dev/null 2>&1

    # location of the plan file
    plan_file="${local_run_path}/.terraform/${local_run_name}.tfplan"

    # don't ask anything, just run
    export TF_INPUT=0

    # set location for the state
    export TF_DATA_DIR="$(pwd)/${local_run_path}/.terraform/${local_run_name}"

    eval terraform init -no-color \
        -backend-config="${cloud}/backend.tfvars" \
        $init_opts \
        -reconfigure \
        "${module_dir}"

    if [ "$action" = "plan" ]; then
        eval terraform plan -no-color \
            $apply_opts \
            -var-file="${full_run_path}.tfvars" \
            -out="${plan_file}" \
            "${module_dir}"

    elif [ "$action" = "apply" ]; then
        eval terraform plan -no-color \
            $apply_opts \
            -var-file="${full_run_path}.tfvars" \
            -out="${plan_file}" \
            "${module_dir}"
        terraform apply -no-color \
            -parallelism="${TF_PARALLELISM}" \
            "${plan_file}"

    elif [ "$action" = "destroy" ]; then
        eval terraform destroy -no-color \
            $apply_opts \
            -var-file="${full_run_path}.tfvars" \
            -auto-approve \
            "${module_dir}"

    elif [ "$action" = "show" ]; then
        pushd "${module_dir}" >/dev/null 2>&1
        echo "module directory: ${module_dir}"
        echo "TF_DATA_DIR: ${TF_DATA_DIR}"
        echo ""
        terraform show
        popd >/dev/null 2>&1

    else
        echo "incorrect action"
        exit 1
    fi
}


function run_legacy() {
    local full_run_path="$1"
    local local_run_name="all"
    local tfstate_path=$(echo "${full_run_path}" |perl -p -e "s/${cloud}\///")

    echo
    echo "Initializing Terraform for ${full_run_path}"
    echo

    export TF_INPUT=0
    export TF_DATA_DIR="$(pwd)/${full_run_path}/.terraform"

    eval terraform init \
        -backend-config="${cloud}/backend.tfvars" \
        -backend-config='key=${tfstate_path}.tfstate' \
        -reconfigure "$full_run_path"

    echo
    echo "Running ${action} on ${full_run_path}"
    echo

    pushd "${full_run_path}" >/dev/null 2>&1
    local plan_file=".terraform/${local_run_name}.tfplan"
    local var_file="../shared.tfvars"

    if [ "$action" = "plan" ]; then
        terraform plan -var-file=$var_file -out="${plan_file}"

    elif [ "$action" = "apply" ]; then
        terraform plan  -var-file=$var_file -out="${plan_file}"
        terraform apply  -auto-approve "${plan_file}"

    elif [ "$action" = "destroy" ]; then
        terraform destroy -var-file=$var_file -auto-approve

    elif [ "$action" = "show" ]; then
        terraform show -var-file=$var_file "${full_run_path}"
    else
        echo "incorrect action"
        exit 1
    fi

    popd >/dev/null 2>&1
}

# If run_path is set to /all, pass in the parent directory
if [[ "${run_path}" == *"/all"* ]]; then
  run_dir ${run_path%/all}
# Check if run_path is a directory, otherwise run as individual module
elif [ -d "${run_path}" ]; then
    run_dir "${run_path}"
elif [ -f "${run_path}.tfvars" ]; then
    run_file "${run_path}"
else
    echo "invalid run path"
    exit 1
fi
