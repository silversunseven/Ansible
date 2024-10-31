#!/bin/bash

# Define the IPs and corresponding hostnames for /etc/hosts
HOST_IPS=("10.0.0.56" "10.0.0.72" "10.0.0.57" "10.0.0.65" "10.0.0.67" "10.0.0.66" "10.0.0.69")
HOSTNAMES=("rh-c" "rhel1" "rhel2" "centos1" "centos2" "ubuntu1" "ubuntu2")

# Define aliases for ~/.zshrc
ZSH_ALIASES=(
    "alias rh-c='ssh -i ~/.ssh/ansible_id_rsa ansible@rh-c'"
    "alias rhel1='ssh -i ~/.ssh/ansible_id_rsa ansible@rhel1'"
    "alias rhel2='ssh -i ~/.ssh/ansible_id_rsa ansible@rhel2'"
    "alias centos1='ssh -i ~/.ssh/ansible_id_rsa ansible@centos1'"
    "alias centos2='ssh -i ~/.ssh/ansible_id_rsa ansible@centos2'"
    "alias ubuntu1='ssh -i ~/.ssh/ansible_id_rsa ansible@ubuntu1'"
    "alias ubuntu2='ssh -i ~/.ssh/ansible_id_rsa ansible@ubuntu2'"
)

# Step 1: Update /etc/hosts
echo "Updating /etc/hosts with Ansible entries..."
HOSTS_HEADER="# Ansible"

if ! grep -q "$HOSTS_HEADER" /etc/hosts; then
    echo "$HOSTS_HEADER" | sudo tee -a /etc/hosts > /dev/null
fi

for i in "${!HOST_IPS[@]}"; do
    IP="${HOST_IPS[$i]}"
    HOSTNAME="${HOSTNAMES[$i]}"
    if ! grep -q "$IP $HOSTNAME" /etc/hosts; then
        echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
        echo "Added $IP $HOSTNAME to /etc/hosts"
    else
        echo "$IP $HOSTNAME already exists in /etc/hosts, skipping..."
    fi
done

# Step 2: Update ~/.zshrc with Ansible aliases
echo "Updating ~/.zshrc with Ansible aliases..."
ZSH_HEADER="# Ansible"

if ! grep -q "$ZSH_HEADER" ~/.zshrc; then
    echo "$ZSH_HEADER" >> ~/.zshrc
fi

for ALIAS in "${ZSH_ALIASES[@]}"; do
    if ! grep -q "$ALIAS" ~/.zshrc; then
        echo "$ALIAS" >> ~/.zshrc
        echo "Added alias: $ALIAS"
    else
        echo "Alias $ALIAS already exists in ~/.zshrc, skipping..."
    fi
done

echo "Updates to /etc/hosts and ~/.zshrc completed. You may need to restart your terminal or source ~/.zshrc for changes to take effect."