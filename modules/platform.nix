{ config, types, lib, ... }: with lib; let
  platformModule = { name, config, lib, ... }: with lib; {
    options = with types; {
      object_id = mkOption {
        type = objectId;
        default = name;
      };
      name = mkOption {
        type = str;
        default = name;
      };
      domain = mkOption {
        type = listOf str;
        default = [ name ];
      };

      get = {
        object_id = mkOption {
          type = functionTo (nullOr str);
          default = if config.entityAttrs.enable
            then _: null
            else { name ? null, ... }: name;
        };
        unique_id = mkOption {
          type = functionTo (nullOr str);
          default = { unique_id ? null, ... }: unique_id;
        };
        name = mkOption {
          type = functionTo (nullOr str);
          default = { name ? null, ... }@args: let
            object_id = config.get.object_id args;
          in if config.entityAttrs.enable || (object_id != null && nameid object_id != mapNullable nameid name) then null
            else name;
        };
        friendly_name = mkOption {
          type = functionTo (nullOr str);
          default = { friendly_name ? null, name ? null, ... }@args: let
            object_id = config.get.object_id args;
          in coalesce [ friendly_name (if config.entityAttrs.enable || object_id != null && nameid object_id != mapNullable nameid name then name else null) ];
        };
      };

      make = mkOption {
        type = functionTo unspecified;
        default = if config.packageKey != null
          then _: flip removeAttrs [ "platform" ]
          else _: create: create // {
            platform = "${config.object_id}";
          };
      };
      packageKey = mkOption {
        type = nullOr str;
        default = if config.entityAttrs.enable then "${config.object_id}" else null;
      };
      apply = mkOption {
        type = nullOr (functionTo unspecified);
        default = if config.entityAttrs.enable
          then entity: {
            "${entity.object_id}" = entity.create.settings;
          } else entity: singleton entity.create.settings;
      };
      entityAttrs = {
        enable = mkEnableOption "explicit object_id assignments";
      };
    };
    config = {
    };
  };
in {
  options = with types; {
    platform = mkOption {
      type = attrsOf (submoduleWith {
        modules = [ platformModule ];
      });
    };
  };
  config.domain.platform = {
    implicitDomain = true;
  };
}
