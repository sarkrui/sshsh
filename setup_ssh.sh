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

# Check if SSH key exists, if not, generate it
if [ ! -f ~/.ssh/id_rsa_m1 ]; then
  echo -e "${YELLOW}SSH key id_rsa_m1 not found. Let's create it.${NC}"
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