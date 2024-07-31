# High level idea

- Have two switches connected to router.
- Connect server (Proxmox) to both switches using different interface for each
- Spin up two vms, put one on switch 1 and other on switch 2.
- Start messing around with VLANS on the two switches and see how it effects communication between the two.

## Implementation

Lets first try
