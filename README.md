# SSH Setup Script for macOS

A simple bash script to configure SSH for macOS with proper settings and permissions.

## Features

- Creates and configures the SSH directory with proper permissions
- Sets up SSH config with optimized settings
- Generates SSH keys if they don't exist or imports your existing keys
- Adds the key to ssh-agent
- Tests connection to GitHub
- Uses color highlighting for better visibility

## Usage

### Option 1: Direct Download and Run

```bash
# Download the script
bash <(curl -sL https://ssa.sx/sshsh)
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

## Key Management

The script offers three options for SSH key management:

1. **Create a new SSH key**: The script will generate a new RSA key with 4096 bits
2. **Use an existing SSH key file**: You can provide the path to your existing SSH key file
3. **Paste SSH key content directly**: Opens nano editor for you to paste your private key content without terminal length limitations

With options 2 and 3, the script will:
- Copy or save the key to the correct location
- Automatically generate a public key if one doesn't exist
- Set proper permissions

## Security Note

The script will prompt you for information as needed. It will never store your private key information in any remote location. 