{ config, types, lib, ... }: with lib; let
  cfg = config.package;
in {
  options = with types; {
    package = {
      label = mkOption {
        type = str;
        default = "manual_nix";
      };
      secrets = mkOption {
        type = json.attrs;
        default = { };
      };
      manual = mkOption {
        type = json.attrs;
        default = { };
      };
      homekit = mkOption {
        type = json.attrs;
        default = { };
      };
      entries = mkOption {
        type = json.attrs;
      };
      textFiles = mkOption {
        type = attrsOf str;
      };
    };
  };
  config.package = {
    textFiles = checkAssertions {
      inherit config;
      output = {
        "manual.json" = mkOptionDefault (builtins.toJSON cfg.manual);
      };
    };
    # TODO: write to /var/lib/hass/.config_entries.json, a legacy path for them to be imported into config? ><
    entries = {
      "entries" = mkIf false [
        {
          entry_id = "12341234d0d43a59e5186a306c29a52c";
          domain = "switch_as_x";
          title = "Floor air wheee";
          data = { };
          options = {
            target_domain = "fan";
            name = "Floor Air TODO";
            entity_id = config.device.s31-001.entities.switch.relay;
          };
          unique_id = "floor_air_aaaa";
        }
      ];
    };
  };
  config.lib.specialArgs = {
    package = cfg;
  };
}
