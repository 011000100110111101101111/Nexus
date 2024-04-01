#!/bin/bash

# Assumptions

# Docker is installed
# You have a docker account (For dockerhub)
# You are logged into docker
# lxc was predeployed
# Ansible is installed

echo -e "Welcome!\nChoose an option:\n\n1. Create new docker image\n2. Edit existing docker image\n3. Deploy Infrastructure"

read -p "Choose an option: " userInput

if [ $userInput -eq 1 ]; then
  read -p $'What base OS do you want to use?\n1. Ubuntu\n2. Alpine\n3. Centos\n4. Fedora\n5. Debian\n6. OpenSUSE\n7. Arch\n8. Busybox\n\n--> ' baseOS
  if [ $baseOS -eq 1 ]; then
    baseOS="ubuntu"
  elif [ $baseOS -eq 2 ]; then
    baseOS="alpine"
  elif [ $baseOS -eq 3 ]; then
    baseOS="centos"
  elif [ $baseOS -eq 4 ]; then
    baseOS="fedora"
  elif [ $baseOS -eq 5 ]; then
    baseOS="debian"
  elif [ $baseOS -eq 6 ]; then
    baseOS="opensuse"
  elif [ $baseOS -eq 7 ]; then
    baseOS="arch"
  elif [ $baseOS -eq 8 ]; then
    baseOS="busybox"
  else
    echo "Invalid option"
    exit 1
  fi
  echo "You chose $baseOS"
  sudo docker pull --quiet $baseOS && echo "Pulled $baseOS"
  echo -e "\n\n===========================================\nExisting Projects\n\n$(sudo docker images -a)\n\n\n"
  read -p "Enter a name for this project: " projectName
  read -p "Enter a tag for this project: " projectTag
  sudo docker run -it --name $projectName $baseOS /bin/bash
  read -p "Are you done editing the instance? (y/n): " doneEditing
  if [ $doneEditing == "y" ]; then

    projectID=$(sudo docker ps -a | grep $projectName | awk '{print $1}')
    sudo docker commit $projectID $projectName:$projectTag
    read -p "Do you want to push this image to dockerhub? (y/n): " pushToDockerhub
    if [ $pushToDockerhub == "y" ]; then
      read -p "Enter your docker username: " dockerUsername
      sudo docker image tag $projectName:$projectTag $dockerUsername/$projectName:$projectTag
      sudo docker image push $dockerUsername/$projectName:$projectTag
    else
      echo "You can edit this instance later by running 'sudo docker start -i $projectName'\nExiting..."
      exit 0
    fi
  else
    echo "Re-entering the instance..."
    sudo docker run -it --name $projectName $baseOS /bin/bash
  fi
elif [ $userInput -eq 2 ]; then
  echo -e "\n$(sudo docker images -a)"
  read -p "Enter the ID of the image you want to edit (YOU MUST ENTER THE ID): " imageName
  sudo docker run -it --name $imageName $imageName /bin/bash
  read -p "Are you done editing the instance? (y/n): " doneEditing
  if [ $doneEditing == "y" ]; then
    projectID=$(sudo docker ps -a | grep $imageName | awk '{print $1}')
    read -p "Enter a new tag for this project: " projectTag
    sudo docker commit $projectID $imageName:$projectTag
    read -p "Do you want to push this image to dockerhub? (y/n): " pushToDockerhub
    if [ $pushToDockerhub == "y" ]; then
      read -p "Enter your docker username: " dockerUsername
      #sudo docker image tag $imageName:$projectTag $dockerUsername/$imageName:$projectTag
      sudo docker image push $dockerUsername/$imageName:$projectTag
    else
      echo -e "You can edit this instance later by running 'sudo docker start -i $imageName'\nExiting..."
      exit 0
    fi
  else
    echo "Re-entering the instance..."
    sudo docker run -it --name $imageName $imageName /bin/bash
  fi
elif [ $userInput -eq 3 ]; then
  # Above is work in progress. Lets instead assume they can operate docker and upload to repo.
  echo -e "1. Small(1-10 students)\n2. Medium(11-40 students)\n3. Large(40+ students)\n"
  read -p "Please choose a resource preset: " resourcePreset
  if [ $resourcePreset -eq 1 ] || [ $resourcePreset[0] == "s" ]; then
    resourcePreset="small"
    num_cpus="2"
    num_memory="2GB"
    num_workers="2"
  elif [ $resourcePreset -eq 2 ] || [ $resourcePreset[0] == "m" ]; then
    resourcePreset="medium"
    num_cpus="4"
    num_memory="4GB"
    num_workers="3"
  elif [ $resourcePreset -eq 3 ] || [ $resourcePreset[0] == "l" ]; then
    resourcePreset="large"
    num_cpus="8"
    num_memory="8GB"
    num_workers="4"
  else
    echo "Invalid option"
    exit 1
  fi
  # Now we can ask a bunch of config options and write it to a file
  read -p "Enter default login name: " loginName
  read -p "Enter default password: " loginPassword
  read -p "Path to public ssh key: " sshKey
  # Now lets write to the file (This is formatted literally, dont change indents/newlines/spacing)
  printf "num_cpus: $num_cpus\nnum_memory: $num_memory\nnum_workers: $num_workers\nloginName: $loginName\nloginPassword: $loginPassword\nsshKey: $sshKey\ncontrol_plane: kmaster\nworker_prefix: kworker\n" >automated-config.yaml
  # Okay.
  cat automated-config.yaml
  read -p "Do you want to deploy the infrastructure now? (y/n): " deployNow
  if [ $deployNow == "y" ]; then
    # Deploy the infrastructure
    echo "Deploying infrastructure..."
    # Ansible script to deploy , assumes lxc setup is already done.
    ansible-playbook -i inventory.ini lxcDeployment/base-cluster-deploy-to-lxc.yml
  fi
fi
