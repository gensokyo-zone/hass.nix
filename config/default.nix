{ ... }: let
  domains = { lib, ... }: {
    config.domain = import ./domains.nix { inherit lib; };
  };
in {
  imports = [
    ./platforms.nix
    ./models.nix
    domains
  ];
}
