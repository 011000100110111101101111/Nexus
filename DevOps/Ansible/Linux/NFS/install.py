from sh import mount
import subprocess
from time import sleep

# For variable substitution
# os.path.expandvars("$PATH")

# Best practice for piping
# ps = subprocess.Popen(('ps', '-A'), stdout=subprocess.PIPE)
# output = subprocess.check_output(('grep', 'process_name'), stdin=ps.stdout)
# ps.wait()

# For sudo, these scripts should be run with elevated privilages OUTSIDE the script "sudo ./script"


# Configuration

# This will be the available share on the nfs server and accessible at /kubernetes
share_to_nfs_directory = "/srv/nfs4/kubernetes"
# This will be linked from local storage to the above share and use its storage
share_from_local = "/opt/kubernetes"

fstab_addition = share_from_local + " " + share_to_nfs_directory + " none   bind    0   0"

exports_addition = \
  "# The IP is the subnet allowed to access the root directory of the NFS server\n"

# TODO Continue here.


subprocess.run(["apt-get update"])
sleep(0.1)
subprocess.run(["apt-get install nfs-kernel-server -y"])
sleep(0.1)
subprocess.run(["mkdir -p", share_to_nfs_directory])
sleep(0.1)
subprocess.run(["mkdir -p", share_from_local])
sleep(0.1)
subprocess.run(["echo", fstab_addition])
sleep(0.1)
subprocess.run([])


