#!/bin/bash
set -eux

if [[ -f /opt/uipath/installed ]]; then
  echo "GPU drivers installed already; skipping ..."
else
  echo "Installing GPU drivers ..."
  yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  sed 's/$releasever/8/g' -i /etc/yum.repos.d/epel.repo
  sed 's/$releasever/8/g' -i /etc/yum.repos.d/epel-modular.repo
  yum config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
  yum install -y cuda

  distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
  dnf clean expire-cache
  dnf install -y nvidia-container-toolkit
  yum install -y nvidia-container-runtime.x86_64
  touch /opt/uipath/installed
  (trap "" SIGPIPE; export HOME="/root"; /root/install-agent.sh)
  /opt/uipath/signal-resource.sh
fi
