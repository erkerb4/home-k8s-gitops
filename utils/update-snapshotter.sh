#!/usr/bin/env bash
# This script is for pulling the latest version snapshot CRDs and snapshot controller

## This GitHub project does not utilize releases
## And multiple major versions are maintained
## We have to be careful with the version

## kubernetes-csi/external-snapshotter releases
## https://github.com/kubernetes-csi/external-snapshotter/releases
set -e

# Repo Root Dir
root_dir=$(git rev-parse --show-toplevel)

## Repo
github_project=kubernetes-csi/external-snapshotter
desired_release=v8.2.1
url=https://raw.githubusercontent.com/${github_project}/${desired_release}

## Get the desired volume snapshot classes
snapshot_url=${url}/client/config/crd/

wget -nc "${snapshot_url}/snapshot.storage.k8s.io_volumesnapshotclasses.yaml" -P ./tmp
wget -nc "${snapshot_url}/snapshot.storage.k8s.io_volumesnapshotcontents.yaml" -P ./tmp
wget -nc "${snapshot_url}/snapshot.storage.k8s.io_volumesnapshots.yaml" -P ./tmp

## Remove old snapshot class files
rm -rf "$root_dir/apps/infra-kubesys/external-snapshotter/crds/*"
rm -rf "$root_dir/apps/infra-kubesys/external-snapshotter/templates/*"

## Move the new snapshot class CRDs
mv ./tmp/snapshot.storage.k8s.io_* $root_dir/apps/infra-kubesys/external-snapshotter/crds/

## Get the desired snapshot controller
controller_url=${url}/deploy/kubernetes/snapshot-controller/

wget -nc "${controller_url}/rbac-snapshot-controller.yaml" -P ./tmp
wget -nc "${controller_url}/setup-snapshot-controller.yaml" -P ./tmp
sed -i 's/k8s-staging-sig-storage/sig-storage/g' ./tmp/setup-snapshot-controller.yaml
sed -i "/sig-storage\/snapshot-controller/c\          image: registry.k8s.io\/sig-storage\/snapshot-controller:${desired_release}" ./tmp/setup-snapshot-controller.yaml

## Move the new files in place
mv ./tmp/*.yaml $root_dir/apps/infra-kubesys/external-snapshotter/templates
