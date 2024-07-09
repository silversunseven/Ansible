# Ansible

## 1. Commission 4 VM's 
The instructions here are primarily for using you mac as a control host and the
managed servers as Ubuntu hosts.
Commision 4 VM's over at your cloud provider. I used https://cloud.digitalocean.com.
Be sure to add your public key to all the servers and call them:

lnx001
lnx002
lnx003
lnx004

## 2. Edit hosts with new IP's

`vi hosts`

->add new ip's

`cat aliases.input >>  ~/.zshrc`

 `source ~/.zshrc`


## 3. Setup Control host

`sudo sh -c 'cat hosts >> /etc/hosts'`

## 4. Setup Users and keys on managed hosts
``` 
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key -N ""
SSH_KEY_CONTENT="$(cat ~/.ssh/ansible_key.pub)"

for host in `cat hosts| awk -F' ' '{ print $1}' |sort |uniq`
do   
  # Create the user awxuser
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "useradd -m -s /bin/bash awxuser"
  # Create the .ssh directory for awxuser
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "mkdir -p /home/awxuser/.ssh/"
  # Copy the public key to the remote host for root
  scp -i ~/.ssh/id_rsa ~/.ssh/ansible_key.pub root@${host}:/home/awxuser/.ssh/authorized_keys
  # Change ownership of the .ssh directory
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "chown -R awxuser:awxuser /home/awxuser/.ssh"
  # Add awxuser to the sudoers file
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "echo 'awxuser ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers"
  # Append the SSH public key to authorized_keys of awxuser
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "echo \"$SSH_KEY_CONTENT\" >> /home/awxuser/.ssh/authorized_keys"

  # Create the user ansible
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "useradd -m -s /bin/bash ansible"
  # Create the .ssh directory for ansible
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "mkdir -p /home/ansible/.ssh/"
  # Copy the public key to the remote host for root
  scp -i ~/.ssh/id_rsa ~/.ssh/ansible_key.pub root@${host}:/home/ansible/.ssh/authorized_keys
  # Change ownership of the .ssh directory
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "chown -R ansible:ansible /home/ansible/.ssh"
  # Add ansible to the sudoers file
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "echo 'ansible ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers"
  # Append the SSH public key to authorized_keys of ansible
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@${host} "echo \"$SSH_KEY_CONTENT\" >> /home/ansible/.ssh/authorized_keys"

done
```




## 3. Connect to the remote server lnx001 and setup Ansible AWX

```
lnx001awx
sudo apt update
sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version

# Install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Install Ansible Core
sudo apt install -y ansible
ansible --version

# Install Node.js (needed for the AWX frontend)
sudo apt install -y nodejs npm

# Install AWX Repo
git clone https://github.com/ansible/awx.git
cd tools/docker-compose
make docker-compose-build

# Deploy AWX using Docker Compose
mkdir -p /data/awx/projects
sudo chown 1000:1000 /data/awx/projects

docker-compose up -d
docker-compose ps
````

## Login
http://164.90.178.212

The default credentials for AWX are:

Username: admin

Password: password

`docker logs <container_id>`
