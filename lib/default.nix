{ lib, entityDomains ? [ ] }: let
  util = import ./util.nix {
    inherit lib hass-lib;
  };
  hass = import ./hass.nix {
    inherit lib hass-lib;
  };
  hass-lib = util // hass // {
    inherit entityDomains;

    cond = import ./cond.nix {
      inherit lib hass-lib;
    };

    trigger = import ./trigger.nix {
      inherit lib hass-lib;
    };

    act = import ./act.nix {
      inherit lib hass-lib;
    };

    inherit (import ./template.nix { inherit lib hass-lib; }) template templated;

    on = "on";
    off = "off";
    unavailable = "unavailable";
    unknown = "unknown";
  };
in hass-lib
