# Update and Upgrade

sudo apt update && sudo apt upgrade -y


# Install NIX

sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Source NIX
. /home/smit/.nix-profile/etc/profile.d/nix.sh

# Install NIX packages

nix-env -iA \
	nixpkgs.zsh \
	nixpkgs.antibody \
	nixpkgs.git \
	nixpkgs.neovim \
	nixpkgs.tmux \
	nixpkgs.stow \
	nixpkgs.yarn \
	nixpkgs.fzf \
	nixpkgs.ripgrep \
	nixpkgs.bat \
	nixpkgs.gnumake \
	nixpkgs.gcc \
	nixpkgs.direnv \
	nixpkgs.delta \
	nixpkgs.fx \
	nixpkgs.glow \
	nixpkgs.exa \
	nixpkgs.zoxide \
	nixpkgs.starship \
	nixpkgs.postgresql \
	nixpkgs.openjdk16-bootstrap \
	nixpkgs.lazygit



# Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Copy all config files to home directory

stow zsh