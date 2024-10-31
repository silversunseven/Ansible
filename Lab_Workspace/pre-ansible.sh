#!/bin/bash

# Define the list of VM IP addresses
declare -a VM_IPS=("10.0.0.56" "10.0.0.72" "10.0.0.57" "10.0.0.65" "10.0.0.67" "10.0.0.66" "10.0.0.69")

# Specify which IP will act as the control host
CONTROL_HOST_IP="10.0.0.56"

# Path to your personal SSH public key that should be copied to root's authorized keys on all VMs
PUBLIC_KEY_PATH="/Users/aryan/.ssh/id_rsa.pub"

# Define Ansible SSH key paths for the control host
ANSIBLE_SSH_KEY_PATH="$HOME/.ssh/ansible_id_rsa"
ANSIBLE_SSH_KEY_PUB_PATH="${ANSIBLE_SSH_KEY_PATH}.pub"

# Generate SSH key for Ansible if it doesn't exist (this key will be used by the control host)
if [ ! -f "$ANSIBLE_SSH_KEY_PATH" ]; then
    echo "Generating SSH key for Ansible..."
    ssh-keygen -t rsa -b 2048 -f "$ANSIBLE_SSH_KEY_PATH" -N ""
fi

# Loop through each VM IP to set up Ansible user
for VM_IP in "${VM_IPS[@]}"; do
    echo "Setting up Ansible user on VM: $VM_IP"

    # Step 1: Copy personal public key to root's authorized_keys on each VM
    echo "Copying personal public key to root@$VM_IP authorized_keys..."
    ssh root@"$VM_IP" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys" < "$PUBLIC_KEY_PATH"

    # Step 2: Create ansible user, set up sudo, and add ansible's public key to authorized_keys on each VM
    ssh root@"$VM_IP" "bash -s" <<EOF
        # Add ansible user if it doesn't exist
        if ! id -u ansible &>/dev/null; then
            useradd -m -s /bin/bash ansible
            echo "Created ansible user"
        else
            echo "User ansible already exists"
        fi

        # Set up passwordless sudo for ansible user
        echo "ansible ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/ansible

        # Set up SSH directory for ansible user and add Ansible SSH key to authorized_keys
        mkdir -p /home/ansible/.ssh
        echo "$(cat $ANSIBLE_SSH_KEY_PUB_PATH)" > /home/ansible/.ssh/authorized_keys
        chown -R ansible:ansible /home/ansible/.ssh
        chmod 600 /home/ansible/.ssh/authorized_keys
EOF

    # Step 3: Install Python if not installed
    ssh root@"$VM_IP" "bash -s" <<'EOF'
        # Check if Python is installed, install if necessary
        if ! command -v python3 &>/dev/null; then
            if [ -f /etc/debian_version ]; then
                sudo apt update && sudo apt install -y python3
            elif [ -f /etc/redhat-release ]; then
                sudo yum install -y python3
            fi
        fi
EOF

    echo "VM $VM_IP setup complete."
done

# Step 4: Configure the control host to connect to target VMs using Ansible user
echo "Configuring control host: $CONTROL_HOST_IP"
ssh root@"$CONTROL_HOST_IP" "bash -s" <<EOF
    # Copy Ansible SSH private key to ansible user's home on control host
    mkdir -p /home/ansible/.ssh
    echo "$(cat $ANSIBLE_SSH_KEY_PATH)" > /home/ansible/.ssh/ansible_id_rsa
    chown -R ansible:ansible /home/ansible/.ssh
    chmod 600 /home/ansible/.ssh/ansible_id_rsa

    # Create the inventory file in the ansible user's home on the control host
    echo "[my_vms]" > /home/ansible/inventory.ini
    chown ansible:ansible /home/ansible/inventory.ini

    # Install Ansible
    sudo yum install ansible-core ansible-collection-redhat-rhel_mgmt -y
EOF

# Append each VM IP to the inventory file on the control host
for VM_IP in "${VM_IPS[@]}"; do
    ssh root@"$CONTROL_HOST_IP" "echo \"$VM_IP ansible_user=ansible ansible_ssh_private_key_file=/home/ansible/.ssh/ansible_id_rsa\" >> /home/ansible/inventory.ini && chown ansible:ansible /home/ansible/inventory.ini"
done

echo "Inventory file created on control host at /home/ansible/inventory.ini"
echo "Setup complete. You can now test from the control host with: ansible -i /home/ansible/inventory.ini my_vms -m ping"
