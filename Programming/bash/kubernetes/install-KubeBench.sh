#!/bin/bash

export KUBVER="0.7.1"

# Download checksums file
wget "https://github.com/aquasecurity/kube-bench/releases/download/v${KUBVER}/kube-bench_${KUBVER}_checksums.txt"

# Download the main file (e.g., kube-bench binary)
#wget "https://github.com/aquasecurity/kube-bench/releases/download/v${KUBVER}/kube-bench_${KUBVER}_linux_amd64.deb"

# Verify the integrity using sha256sum
calculated_sha256=$(sha256sum kube-bench_${KUBVER}_linux_amd64.deb | awk '{print $1}')
expected_sha256=$(grep kube-bench_${KUBVER}_linux_amd64.deb kube-bench_${KUBVER}_checksums.txt | awk '{print $1}')

# Compare the calculated and expected checksums
if [ "$calculated_sha256" == "$expected_sha256" ]; then
  echo "Checksums match. File integrity verified."
else
  echo "Checksums do not match. File integrity could not be verified."
fi

sudo dpkg -i ./kube-bench_${KUBVER}_linux_amd64.deb

rm kube-bench_${KUBVER}_checksums.txt
rm kube-bench_${KUBVER}_linux_amd64.deb

# Optional removal
# sudo dpkg -r kube-bench
