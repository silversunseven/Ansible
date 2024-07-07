# Ansible

## 1. Commission 4 VM's over your favorite platform
The instructions here are primarily for the Ubuntu OS.
Commision 4 VM's over at your cloud provider. Be sure to add your public key to all the servers and call them:

lnx001
lnx002
lnx003
lnx004

and take note of the IP's
## 2. Edit aliases and add them to your .bashrc

`vi aliases.input`
 
->update with server IP's

`vi id_rsa.pub`
 
->add public Key

`cat aliases.input >>  ~/.bashrc`

## 3. Setup Users and keys on hosts
``` 
for ip in `cat aliases.input | awk -F'@' '{ print $2}' |sed 's/.$//g' |sort |uniq`
do   
  ssh -i ~/.ssh/id_rsa root@${ip} useradd -m -s /bin/bash awxuser
  ssh -i ~/.ssh/id_rsa root@${ip} sudo usermod -aG sudo awxuser
  ssh -i ~/.ssh/id_rsa root@${ip} mkdir -p /home/awxuser/.ssh/
  scp -i ~/.ssh/id_rsa id_rsa.pub root@${ip}:/home/awxuser/.ssh/authorized_keys
  ssh -i ~/.ssh/id_rsa root@${ip} chown -R awxuser:awxuser /home/awxuser/.ssh
  ssh -i ~/.ssh/id_rsa root@${ip} echo "awxuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


  ssh -i ~/.ssh/id_rsa root@${ip} useradd -m -s /bin/bash ansible
  ssh -i ~/.ssh/id_rsa root@${ip} sudo usermod -aG sudo ansible
  ssh -i ~/.ssh/id_rsa root@${ip} mkdir -p /home/ansible/.ssh/
  scp -i ~/.ssh/id_rsa id_rsa.pub root@${ip}:/home/ansible/.ssh/authorized_keys
  ssh -i ~/.ssh/id_rsa root@${ip} chown -R ansible:ansible /home/ansible/.ssh
  ssh -i ~/.ssh/id_rsa root@${ip} echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
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
apt install -y nodejs npm

# Install AWX Repo
git clone https://github.com/ansible/awx.git
cd awx/installer



