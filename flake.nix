{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs-channels/nixos-unstable;
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix, self, ... }@inputs: {
    nixosConfigurations.flix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        (import ./configuration.nix)
        inputs.home-manager.nixosModules.home-manager
      ];
      specialArgs = { inherit inputs; };
    };

    flix = self.nixosConfigurations.flix.config.system.build.toplevel;
  };
}
