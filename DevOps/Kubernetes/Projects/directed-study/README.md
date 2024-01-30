# Directed study with Professor Sashank


## Goal

Using kubernetes to automate the deployment of lab envirements for school courses.

End Goal Abilities


Input
- Professor specifies what resources they need
- Professor specifies number of students they have


Middleman
- Interprets needs, provisions kubernetes cluster
- Seperate network for every student
- One for the professor, one for the students.


Output
- Teacher is provided infastructure where they can now deploy + scale their lab.
- They should be provided an interface where they can do this all.
- After they decide their lab, they should be able to press a button and it is deployed to all the students.


Basically whatever the teacher does on their infastructure, it should be replicated on the students infastructure.

## Details


- Professor has dev envirement, and production envirement.
- Provide a way of checkpointing, hey this is done in dev, move it to production. Any changes on prod are not sent to students, 
- Have cluster with dev, prod. CI/CD pipeline between the two for continued development.
- Have a point where they 
- Have a web frontend where they have a blank slate, they have an option "Create container" , "Create VM", etc
  - Then they can click create, and it'll deploy and be given noVNC interface to it.
  - We could do a seperate teacher vm, where they develop what they want then they can snapshot.