---
layout: post
title: Microceph Cluster Deployment Guide
date: 2024-02-16
summary: Covers deploying and setting up microceph across multiple nodes allowing for HA storage
categories: guides
---

The microceph package makes setting up a cluster easier. It includes numerous dependencies required.

**Guide results**

- ceph cluster deployed across 3 nodes allowing simple HA storage

**Prerequisites / Important Information**

- Everything is done on Ubuntu 22.04 LTS server.
- You must have atleast 3 nodes.

## Cluster Deployment

Install microceph on all the nodes you want to run it on.

```bash
sudo snap install microceph
```

Then, we will bootstrap the cluster. You should do this on 1 system, then join the others with output. The command below will install everything needed to run the cluster.

```bash
sudo microceph cluster bootstrap
```

Lets confirm it worked

```bash
sudo microceph status
```

Okay, now lets add the other machines. Run this command on the machine you just deployed the cluster on, and substitute hostname with the name of the other machine / machines you want to join. (Run it once for each machine, it has unique output)

```bash
sudo microceph cluster add <hostname>
```

The above will output a token. On the system you want to JOIN to the cluster, run this command.

```bash
sudo microceph cluster join <token>
```

Again, we can confirm it successfully joined by running the following command. However, this time we can run it on any of the machines you joined already.

```bash
sudo microceph status
```

## Adding disks to the cluster

Ideally you would have a seperate disk that you could add as storage. If you did, you would simply run the following command. Keep in mind this will `WIPE` the disk.

```bash
sudo microceph disk add /dev/<disk> --wipe
```

In the scenario you do not have a dedicated disk, do not fear! We will create a loop device. The following command will create a loop device on the device you run it. You will most likely want to run this on all devices on the cluster.

```bash
sudo microceph disk add loop,5G,1
```

- loop = dynamically generated
- 5G = 5 gigabytes of space
- 1 = only 1 disk.

Check success again,

```bash
user@k8-master-1:~$ sudo microceph status

MicroCeph deployment summary:
- k8-master-1 (192.168.3.200)
  Services: mds, mgr, mon, osd
  Disks: 1
- k8-worker-1 (192.168.3.210)
  Services: mds, mgr, mon, osd
  Disks: 1
- k8-worker-2 (192.168.3.211)
  Services: mds, mgr, mon, osd
  Disks: 1

user@k8-master-1:~$ sudo microceph.ceph status

cluster:
  id:     d42b062f-19ee-478f-9e1c-781f6b86eb24
  health: HEALTH_OK

services:
  mon: 3 daemons, quorum k8-master-1,k8-worker-1,k8-worker-2 (age 8m)
  mgr: k8-master-1(active, since 13m), standbys: k8-worker-1, k8-worker-2
  osd: 3 osds: 3 up (since 53s), 3 in (since 73s)

data:
  pools:   1 pools, 1 pgs
  objects: 2 objects, 577 KiB
  usage:   81 MiB used, 30 GiB / 30 GiB avail
  pgs:     1 active+clean
```

Okay, we have the disk setup, now we need to create a pool.

```bash
sudo microceph.ceph osd pool create kubernetes-pool
```

- osd = Your type (disks) that you just added. If you check .ceph output you can see the osd under services.
- pool = type
- create = action to do, create the pool
- kubernetes-pool = name of pool, change to what you want

Currently, the pool is created but not initilized. Lets do that.

```bash
sudo microceph.rbd pool init kubernetes-pool
```

Your pool is now ready and you can actually put files onto it now. You can ALSO create disks on this pool. Lets say you wanted a data disk for kubernetes to be seperate from everything else, you can do the following,

```bash
sudo microceph.rbd create data-disk1 --size 2G --image-feature layering -k <keyring file, see command below> -p kubernetes-pool

# Example
sudo microceph.rbd create data-disk1 --size 2G --image-feature layering -k /var/snap/microceph/862/conf/ceph.keyring -p kuberne
tes-pool
```

- create = action, create next thing
- data-disk1 = disk name
- --size 2GB = 2GB of space
- --image-feature layering =
- -k = keyring file, (sudo find / -name ceph.keyring)
- -p = pool to run this on

## Accessing the cluster from an outside system

Okay, lets put some extra use to what we created. First you need to install ceph tools on the external system.

```bash
sudo apt install ceph-common
```

To initilize ceph on this system, we would go to `/etc/ceph` and create two files.

The first would be the ceph.conf file from one of the cluster machines.

```bash
# On any cluster machine, run the following to find the conf file
sudo find / -name "ceph.conf"

# Either copy from remote or local using scp

# If you run the command on the cluster machine
sudo scp <pathFromAbove> user@remoteIP:/destinationPath

# If you run the command on the local machine
sudo scp user@remoteIP:<pathFromAbove> destinationPath
```

The second would be the ceph.keyring file from one of the clsuter machines.

```bash
# On any cluster machine, run the following to find the keyring file. This has more strict permissions, so you will manually copy it over.
sudo find / -name "ceph.keyring"
sudo cat <outputFromAbove>

# Copy that over to your machine and paste into a file called ceph.keyring
sudo vi ceph.keyring
# If you get stuck in vi,
# esc
# shift+:
# wq
# enter
# Then, change permissions for that file for only root access
sudo chmod 640 ceph.keyring

# Then check you can access the cluster. Must use sudo since we restricted the keyring file
sudo ceph status
```

After creating these two files, we can now make use of the cluster. Lets mount one of the disks we created above from the kubernetes pool. We want to create an entry in rdbmap to mount this.

```bash
sudo vim /etc/ceph/rbdmap
```

Below is an example of what you would enter.

```bash
# RbdDevice             Parameters
#poolname/imagename     id=client,keyring=/etc/ceph/ceph.client.keyring
kubernetes-pool/data-disk1 id=admin,keyring=/etc/ceph/ceph.keyring
```

- kubernetes-pool = The pool you want to use.
- data-disk1 = The disk you created inside the pool.
- id=admin = id you want to mount it with
- keyring = path to your local keyring file

We will now restart rbdmap service so it picks up on the new config.

```bash
sudo systemctl restart rbdmap
```

Check your new disk

```bash
ls -la /dev/rbd/<poolName>/<diskName>

# Example
ls -la /dev/rbd/kubernetes-pool/data-disk1
```

Then, to mount it locally,

```bash
# Create the local directory we will mount it too
sudo mkdir /local-data-directory-1
# Format the disk from the cluster if it isnt already
sudo mkfs.ext4 /dev/rbd/kubernetes-pool/data-disk1
# Mount it
sudo mount -t ext4 /dev/rbd/kubernetes-pool/data-disk1 /local-data-directory-1
# Now, wherever this is mounted on other systems it will be available HA!
```

If you want to make it permanent add the following to your `/etc/fstab` file. It would look like the following,

```bash
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during curtin installation
/dev/rbd/kubernetes-pool/data-disk1 /local-data-directory-1 ext4 defaults 0 1
```

TODO: Dashboard
