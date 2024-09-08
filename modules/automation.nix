let
  automationSettingsModule = { name, config, types, lib, ... }: with lib; {
    options = with types; {
      mode = mkOption {
        type = enum [ "single" "restart" "queued" "parallel" ];
        default = "single";
      };
    };
    config = {
      _module.freeformType = types.json.attrs;
    };
  };
  triggeredModule = { package, name, config, types, lib, ... }: with lib; {
    options = with types; {
      id = mkOption {
        type = str;
        default = name;
      };
      enable = mkEnableOption "trigger" // { default = true; };
      trigger = mkOption {
        # TODO: toListOf
        type = triggerType;
      };
      action = mkOption {
        type = toListOf actionType;
      };
      condition = mkOption {
        type = toListOf conditionType;
      };
      settings = mkOption {
        type = json.attrs;
      };
    };
    config = {
      condition = mkBefore [
        (cond.trigger { inherit (config) id; })
      ];
      settings = {
        trigger = mkMerge [
          config.trigger.settings
          {
            id = mkDefault config.id;
          }
        ];
      };
    };
  };
  automationModule = { meta, package, name, config, types, lib, ... }: with lib; {
    options = with types; {
      label = mkOption {
        type = str;
        default = package.label;
      };
      disable = mkOption {
        type = bool;
        default = false;
      };

      triggered = mkOption {
        type = attrsOf (submoduleWith {
          modules = [ triggeredModule ];
          specialArgs = meta.lib.specialArgs // {
            automation = config;
          };
        });
        default = { };
      };
      trigger = mkOption {
        type = toListOf triggerType;
        default = [ ];
      };
      action = mkOption {
        type = toListOf actionType;
        default = [ ];
      };
      condition = mkOption {
        type = toListOf conditionType;
        default = [ ];
      };

      variables = mkOption {
        type = json.attrs;
        default = { };
      };
      triggerVariables = mkOption {
        type = json.attrs;
        default = { };
      };

      settings = mkOption {
        type = submoduleWith {
          modules = [ automationSettingsModule ];
          specialArgs = meta.lib.specialArgs // {
            automation = config;
          };
        };
      };
    };
    config = let
      triggered = filterAttrs (_: trigger: trigger.enable) config.triggered;
    in {
      unique_id = mkIf (config.settings.id or null != null) (mkDefault config.settings.id);
      trigger = mkMerge (
        mapAttrsToList (_: trigger: trigger.settings.trigger) triggered
      );
      action = mkIf (triggered != { }) (
        act.choose (mapAttrsToList (name: trigger: {
          conditions = trigger.condition;
          sequence = mapSettings trigger.action;
          alias = "triggered.${name}";
        }) triggered) null
        // {
          alias = "choose trigger";
        }
      );
      settings = {
        alias = config.object_id.name;
        id = mkOptionDefault name;
        action = map getSettings config.action;
        trigger = map getSettings config.trigger;
        condition = mkIf (config.condition != [ ]) config.condition;
        variables = mkIf (config.variables != { }) config.variables;
        trigger_variables = mkIf (config.triggerVariables != { }) config.triggerVariables;
      };
      condition = mkIf config.disable [
        cond.false
      ];
    };
  };
in { config, types, lib, ... }: with lib; let
  cfg = config.entities.automation;
in {
  config = let
    automations = groupBy (automation: automation.label) (attrValues cfg);
  in {
    package.manual = mapAttrs' (label: automations: nameValuePair "automation ${label}" (map getSettings automations)) automations;
    domain.automation = {
      freeform = false;
      modules = [ automationModule ];
      entity = {
        enable = true;
        manual = true;
      };
    };
  };
}
