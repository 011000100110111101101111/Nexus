# Directed study with Professor Sashank

## Summarized Overview

Use CICD pipeline via Jenkins / ArgoCD and Gitlab to test chosen infrastructure by "Professor". Upon validation push to automated lxc + cluster deployment.

Timeline is difficult to pin down, however most likely 1 week of researching options, 2 weeks for infrastructure phase, 3 weeks for CICD phase, 2 weeks for UI phase, 1 week for Interaction Phase. This would land "rough completition" around the middle of April. The timeline is assuming the 4 hours per week, and could increase if more time is allocated (Less CCDC).

To keep with reality, we should treat this timeline as fluid to accommodate considering different options and running into unknown issues. Ideally all stages can be completed, but if not, all parts will be heavily documented to be continued after the arranged time passes by someone else or myself.

## Goal

Using kubernetes to automate the deployment of lab environment for school courses.

End Goal Abilities

Input

- Professor specifies what resources they need
- Professor specifies number of students they have

Middleman

- Interprets needs, provisions kubernetes cluster
- Seperate network for every student
- One for the professor, one for the students.

Output

- Teacher is provided infrastructure where they can now deploy + scale their lab.
- They should be provided an interface where they can do this all.
- After they decide their lab, they should be able to press a button and it is deployed to all the students.

Basically whatever the teacher does on their infrastructure, it should be replicated on the students infrastructure.

## Details

- Professor has dev environment, and production environment.
- Provide a way of checkpointing, hey this is done in dev, move it to production. Any changes on prod are not sent to students,
- Have cluster with dev, prod. CI/CD pipeline between the two for continued development.
- Have a point where they
- Have a web frontend where they have a blank slate, they have an option "Create container" , "Create VM", etc
  - Then they can click create, and it'll deploy and be given noVNC interface to it.
  - We could do a seperate teacher vm, where they develop what they want then they can snapshot.

## Thoughts for initial approach at a high level

Professor is presented UI, chooses components (Assume done)

Use a pipeline to ensure it will work before creating the cluster. Then we could provision in the following,

Based on selected images (Associate resource requirements with them), provision a new cluster using LXC. Each "assignment" should be segregetated to a new cluster, for easy management, replication, deletion, etc. (Its lxc so its lightweight anyways)

So ideally, this would be code entering a CICD which triggers the cluster creation.

## Steps

### Initial Phase

Do a bit more research to see if there is more efficient ways to do this (stuff like kodekloud clearly have this down as an art)

### Base infrastructure Phase

Endgoal in this stage:

Deploy lxc, then deploy clusters. Have ability to clean these instances as well for easy removal.

### CI/CD Integration Phase

Endgoal in this stage:

```bash
create <type> <resources>
```

The goal here is to be able to type the command above and have it deploy lxc instances, and create clusters on them with the specified resources (storage, ram, cpu, etc).

The type would start simple, lets say "webserver" and there is a deployed webserver. This would later be expanded to deploy scenarios that they create on the interface.

After accomplishing that, create the ability to interact with the base infrastructure deployment using CI/CD

Possible options,

Jenkins or argocd.

### UI Phase

Endgoal in this stage:

User are presented with elements from a UI.

This will be more of a frontend stage.

### Interaction Phase

Connect the UI with CICD. Finalization stage basically, includes cleanup.

### Technologies to explore in this setup

Orchestration - Kubernetes

"VM" Deployment - LXC (Sidethought here, have been experimenting with kubevirt, clusters inside of clusters? (Maybe too complex))

Storage - CEPH, NFS, lot of options here that all integrate seamlessly with kubernetes

CICD - Jenkins / Argo / Gitlab
