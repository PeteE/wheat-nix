nix-build '<nixpkgs/nixos>' \
	--cores 0 \
	-I nixos-config=image.nix \
	-I nixpkgs=channel:nixos-24.05 \
	-I nixos-unstable=channel:nixos-24.05 \
	-A config.system.build.sdImage \
	-o result-cross \
	--show-trace

