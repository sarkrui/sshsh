#!/bin/bash

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==== macOS SSH Setup Script ====${NC}"

# Create ~/.ssh directory if it doesn't exist
if [ ! -d ~/.ssh ]; then
  echo -e "${YELLOW}Creating ~/.ssh directory...${NC}"
  mkdir -p ~/.ssh
  echo -e "${GREEN}Created ~/.ssh directory${NC}"
else
  echo -e "${GREEN}~/.ssh directory already exists${NC}"
fi

# Set proper permissions for ~/.ssh directory
echo -e "${YELLOW}Setting proper permissions for ~/.ssh directory...${NC}"
chmod 700 ~/.ssh
echo -e "${GREEN}Permissions set for ~/.ssh directory${NC}"

# Create/update SSH config
echo -e "${YELLOW}Creating SSH config file...${NC}"
cat > ~/.ssh/config << 'EOL'
Host *
	KexAlgorithms +diffie-hellman-group14-sha1
    ConnectTimeout 30
    ServerAliveInterval 30
    ControlMaster auto
    ControlPersist 60s
    HashKnownHosts yes
    GSSAPIAuthentication no
    IdentitiesOnly yes
    Compression yes

Host gh
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_m1
EOL

echo -e "${GREEN}SSH config file created${NC}"

# Set proper permissions for config file
echo -e "${YELLOW}Setting proper permissions for SSH config...${NC}"
chmod 600 ~/.ssh/config
echo -e "${GREEN}Permissions set for SSH config${NC}"

# Check if SSH key exists, if not, give options
if [ ! -f ~/.ssh/id_rsa_m1 ]; then
  echo -e "${YELLOW}SSH key id_rsa_m1 not found.${NC}"
  echo -e "${BLUE}Choose an option:${NC}"
  echo -e "  ${GREEN}1)${NC} Create a new SSH key"
  echo -e "  ${GREEN}2)${NC} Use an existing SSH key file"
  echo -e "  ${GREEN}3)${NC} Paste SSH key content directly"
  read -p "Enter your choice (1, 2 or 3): " key_choice
  
  if [ "$key_choice" = "1" ]; then
    # Create a new key
    echo -e "${YELLOW}Creating a new SSH key...${NC}"
    echo -e "${BLUE}Please enter an email to associate with this SSH key:${NC}"
    read email
    
    ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa_m1
    
    # Set proper permissions for the key files
    echo -e "${YELLOW}Setting proper permissions for SSH keys...${NC}"
    chmod 600 ~/.ssh/id_rsa_m1
    chmod 644 ~/.ssh/id_rsa_m1.pub
    echo -e "${GREEN}Permissions set for SSH keys${NC}"
    
    # Display the public key for the user
    echo -e "${BLUE}Your public key:${NC}"
    cat ~/.ssh/id_rsa_m1.pub
    
    echo -e "${YELLOW}Add this public key to your GitHub account:${NC}"
    echo -e "${BLUE}https://github.com/settings/keys${NC}"
  elif [ "$key_choice" = "2" ]; then
    # Use existing key file
    echo -e "${YELLOW}Using an existing SSH key file...${NC}"
    echo -e "${BLUE}Enter the path to your existing private key:${NC}"
    read existing_key_path
    
    if [ -f "$existing_key_path" ]; then
      # Copy the existing key
      cp "$existing_key_path" ~/.ssh/id_rsa_m1
      
      # Check if there's a corresponding public key
      if [ -f "${existing_key_path}.pub" ]; then
        cp "${existing_key_path}.pub" ~/.ssh/id_rsa_m1.pub
        echo -e "${GREEN}Both private and public keys copied${NC}"
      else
        echo -e "${YELLOW}No corresponding public key found. Generating public key from private key...${NC}"
        ssh-keygen -y -f ~/.ssh/id_rsa_m1 > ~/.ssh/id_rsa_m1.pub
        echo -e "${GREEN}Public key generated${NC}"
      fi
      
      # Set proper permissions for the key files
      echo -e "${YELLOW}Setting proper permissions for SSH keys...${NC}"
      chmod 600 ~/.ssh/id_rsa_m1
      chmod 644 ~/.ssh/id_rsa_m1.pub
      echo -e "${GREEN}Permissions set for SSH keys${NC}"
      
      # Display the public key for the user
      echo -e "${BLUE}Your public key:${NC}"
      cat ~/.ssh/id_rsa_m1.pub
      
      echo -e "${YELLOW}Add this public key to your GitHub account:${NC}"
      echo -e "${BLUE}https://github.com/settings/keys${NC}"
    else
      echo -e "${RED}Error: The specified key file does not exist.${NC}"
      exit 1
    fi
  elif [ "$key_choice" = "3" ]; then
    # Paste SSH key content directly using nano
    echo -e "${YELLOW}You'll now be able to paste your SSH private key directly.${NC}"
    echo -e "${BLUE}Nano editor will open. Paste your private key, then press Ctrl+X, Y, Enter to save.${NC}"
    echo -e "${YELLOW}Press any key to continue...${NC}"
    read -n 1 -s
    
    # Create empty file with right permissions first
    touch ~/.ssh/id_rsa_m1
    chmod 600 ~/.ssh/id_rsa_m1
    
    # Open nano for editing
    nano ~/.ssh/id_rsa_m1
    
    echo -e "${GREEN}Private key saved.${NC}"
    
    # Generate public key from private key
    echo -e "${YELLOW}Generating public key from private key...${NC}"
    ssh-keygen -y -f ~/.ssh/id_rsa_m1 > ~/.ssh/id_rsa_m1.pub 2>/dev/null
    
    if [ $? -eq 0 ]; then
      chmod 644 ~/.ssh/id_rsa_m1.pub
      echo -e "${GREEN}Public key generated${NC}"
      
      # Display the public key for the user
      echo -e "${BLUE}Your public key:${NC}"
      cat ~/.ssh/id_rsa_m1.pub
      
      echo -e "${YELLOW}Add this public key to your GitHub account:${NC}"
      echo -e "${BLUE}https://github.com/settings/keys${NC}"
    else
      echo -e "${RED}Error: Could not generate public key. The private key may be invalid.${NC}"
      echo -e "${YELLOW}You can try again or continue without a public key.${NC}"
      read -p "Do you want to continue anyway? (y/n): " continue_choice
      if [ "$continue_choice" != "y" ]; then
        exit 1
      fi
    fi
  else
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}SSH key id_rsa_m1 already exists${NC}"
fi

# Start ssh-agent and add the key
echo -e "${YELLOW}Starting ssh-agent and adding key...${NC}"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_m1
echo -e "${GREEN}SSH key added to ssh-agent${NC}"

# Test connection to GitHub
echo -e "${YELLOW}Testing connection to GitHub...${NC}"
echo -e "${BLUE}You might be prompted to confirm the host fingerprint.${NC}"
ssh -T git@github.com 2>&1 | grep "successfully authenticated" > /dev/null
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Successfully connected to GitHub${NC}"
else
  echo -e "${RED}Failed to connect to GitHub. Please check your configuration and try again.${NC}"
fi

echo -e "${BLUE}==== SSH Setup Complete ====${NC}"
echo -e "${YELLOW}Your SSH environment has been configured with the following:${NC}"
echo -e "${BLUE}- SSH directory: ${GREEN}~/.ssh${NC}"
echo -e "${BLUE}- SSH config: ${GREEN}~/.ssh/config${NC}"
echo -e "${BLUE}- SSH key: ${GREEN}~/.ssh/id_rsa_m1${NC}"
echo -e "${BLUE}- GitHub host alias: ${GREEN}gh${NC} (use as 'git clone gh:username/repo.git')" 