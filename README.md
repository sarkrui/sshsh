# SSH Setup Script for macOS

A simple bash script to configure SSH for macOS with proper settings and permissions.

## Features

- Creates and configures the SSH directory with proper permissions
- Sets up SSH config with optimized settings
- Generates SSH keys if they don't exist
- Adds the key to ssh-agent
- Tests connection to GitHub
- Uses color highlighting for better visibility

## Usage

### Option 1: Direct Download and Run

```bash
# Download the script
curl -o setup_ssh.sh https://ssa.sx/sshsh

# Make it executable
chmod +x setup_ssh.sh

# Run the script
./setup_ssh.sh
```

### Option 2: Download and Run in One Command

```bash
curl -s https://ssa.sx/sshsh | bash
```

## SSH Configuration

The script configures SSH with the following settings:

```
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
```

This configuration includes:
- GitHub host alias for easy cloning: `git clone gh:username/repo.git`
- Optimized connection settings
- Proper security settings

## Security Note

The script will prompt you for an email address to associate with your SSH key. It will never store your private key information in any remote location. 