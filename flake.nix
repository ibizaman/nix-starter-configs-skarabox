{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    skarabox.url = "github:ibizaman/skarabox";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    deploy-rs.url = "github:serokell/deploy-rs";
    colmena.url = "github:zhaofengli/colmena";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    ...
  } @ inputs: flake-parts.lib.mkFlake { inherit inputs; } (let
    inherit (self) outputs;
  in {
    imports = [
      inputs.skarabox.flakeModules.default
    ];

    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    perSystem = { self', inputs', config, pkgs, system, ... }: {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = import ./pkgs nixpkgs.legacyPackages.${system};
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    };

    skarabox.hosts = {
      myskarabox = {
        system = ./myskarabox/system;
        hostKeyPath = "./myskarabox/host_key";
        hostKeyPub = ./myskarabox/host_key.pub;
        ip = ./myskarabox/ip;
        sshPrivateKeyPath = "./myskarabox/ssh";
        sshPublicKey = ./myskarabox/ssh.pub;
        knownHosts = ./myskarabox/known_hosts;
        knownHostsPath = "./myskarabox/known_hosts";
        secretsFilePath = "./myskarabox/secrets.yaml";

        modules = [
          inputs.sops-nix.nixosModules.default
          ./myskarabox/configuration.nix
        ];
      };
    };

    flake = {
      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays {inherit inputs;};
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # FIXME replace with your hostname
        your-hostname = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            # > Our main nixos configuration file <
            ./nixos/configuration.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        # FIXME replace with your username@hostname
        "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {inherit inputs outputs;};
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/home.nix
          ];
        };
      };
    };
  });
}
