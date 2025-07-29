# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is Pete's NixOS Flake configuration repository that manages system configurations for multiple hosts across different architectures using the Snowfall Lib framework. The repository follows a modular approach to manage NixOS systems, Darwin systems, and Home Manager configurations.

## Architecture

### Core Structure

- **Snowfall Lib Framework**: Uses `snowfall-lib.mkFlake` for organizing modules, systems, and homes
- **Namespace**: All modules are under the `wheat` namespace
- **Multi-platform support**: Supports x86_64-linux, aarch64-linux, and aarch64-darwin

### Directory Organization

```
├── flake.nix              # Main flake configuration with inputs and outputs
├── modules/
│   ├── shared/wheat/       # Shared configuration module with user, SSH, fonts
│   ├── home/wheat/         # Home Manager modules (AI tools, dev tools, etc.)
│   ├── nixos/wheat/        # NixOS-specific modules (Plasma, virtualization, etc.)
│   └── darwin/wheat/       # Darwin-specific modules
├── homes/                  # Home Manager configurations per user@host
├── systems/                # System configurations per host
└── packages/               # Custom packages (if any)
```

### Key Components

1. **Shared Module** (`modules/shared/wheat/default.nix`):
   - Defines the main `wheat` configuration options
   - Manages user creation, SSH keys, fonts, and basic services
   - Configures OpenSSH, Tailscale, and DNS settings

2. **Home Configurations**: Each user@host combination has specific configs
   - Example: `homes/x86_64-linux/petee@x1/default.nix`

3. **System Configurations**: Host-specific system configurations
   - Example: `systems/x86_64-linux/x1/default.nix`

## Development Commands

This is a Nix Flake repository. Common commands:

```bash
# Build and switch system configuration (NixOS) - preferred method using nh
nh os switch ~/dev/wheat-nix#nixosConfigurations.<hostname>

# Alternative: Build and switch system configuration (NixOS)
sudo nixos-rebuild switch --flake .#<hostname>

# Build and switch user configuration (Home Manager)
home-manager switch --flake .#<user>@<hostname>

# Build specific configuration without switching
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
nix build .#homeConfigurations."<user>@<hostname>".activationPackage

# Update flake inputs
nix flake update

# Check flake
nix flake check

# Show flake outputs
nix flake show
```

### Active Hosts

- **x1**: x86_64-linux laptop (Lenovo ThinkPad X1 6th gen)
- **m4**: aarch64-darwin Mac
- **m3p**: aarch64-darwin Mac
- **pishield**: aarch64-linux Raspberry Pi 4

## Module System

### Enabling Features

Most functionality is controlled through `wheat.*` options:

```nix
wheat = {
  enable = true;                    # Enable base wheat configuration
  secrets.enable = true;            # Enable SOPS secrets management
  user.name = "petee";             # Set username
  # ... other options
};
```

### Common Modules

- **AI Tools** (`wheat.ai.enable`): Includes claude-code, aichat with API key management
- **Secrets** (`wheat.secrets.enable`): SOPS-based secret management with age encryption
- **Development Tools**: Various dev tool configurations in `modules/home/wheat/`

### Secret Management

Uses SOPS with age encryption:
- Secrets file: `modules/home/wheat/secrets/secrets.yaml`
- Age key location: `~/.config/sops/age/keys.txt`
- API keys for OpenAI, Anthropic, AssemblyAI automatically exported as environment variables

**SOPS Commands:**
- Edit secrets: `sops edit modules/home/wheat/secrets/secrets.yaml`
- Fix key mismatch errors: `sops updatekeys modules/home/wheat/secrets/secrets.yaml`

## Configuration Patterns

1. **Module Structure**: Each module follows the standard pattern:
   ```nix
   { options.wheat.<module> = { enable = mkEnableOption "..."; };
     config = mkIf cfg.enable { ... }; }
   ```

2. **Cross-platform Compatibility**: Uses `isDarwin` checks for platform-specific configurations

3. **User Management**: Centralized user configuration in shared module with SSH key management

## Notes

- Repository uses vim-style settings: `ts=2:sw=2:et` (2-space indentation)
- All SSH keys are managed centrally in the shared wheat module
- Secrets are encrypted and managed through SOPS/age
- The flake follows nixos-unstable channel for latest packages