let
  espresenseDeviceSettingsModule = { name, config, types, lib, ... }: with lib; {
    options = with types; {
      object_id = mkOption {
        type = objectId;
        default = name;
      };
      settings = mkOption {
        type = json.attrs;
      };
    };
    config = {
      settings = {
        name = mkIf (config.object_id.object_id != config.object_id.name) (mkOptionDefault config.object_id.name);
        id = mkOptionDefault "alias:${config.object_id}";
      };
    };
  };
  espresenseRoomModule = { name, meta, config, types, lib, ... }: with lib; let
    defaultRoomSettings = mapAttrs (_: mkOptionDefault) meta.espresense.roomSettings;
  in {
    options = with types; {
      object_id = mkOption {
        type = objectId;
        default = name;
      };
      ibeacon = mkOption {
        type = ibeaconId;
      };
      area = mkOption {
        type = nullOr (hassRef "area");
        default = meta.area."${config.object_id}" or null;
      };
      dht22 = {
        enable = mkEnableOption "DHT22" // {
          default = config.dht22.gpio != null;
        };
        gpio = mkOption {
          type = nullOr int;
          default = null;
        };
      };
      radar = {
        enable = mkEnableOption "Radar" // {
          default = config.radar.gpio != null;
        };
        part = mkOption {
          type = nullOr str;
          default = null;
        };
        gpio = mkOption {
          type = nullOr int;
          default = null;
        };
        timeout = mkOption {
          type = float;
          default = 5.0;
        };
      };
      settings = mkOption {
        type = attrsOf espresenseMqttType;
      };
    };
    config = {
      ibeacon.uuid = mkDefault "e5ca1ade-f007-ba11-0000-000000000000";
      settings = mkMerge [ defaultRoomSettings {
        radar = mkIf config.radar.enable config.radar.enable;
        radar_timeout = mkIf config.radar.enable config.radar.timeout;
      } ];
    };
  };
in { config, types, lib, ... }: with lib; let
  cfg = config.espresense;
in {
  options.espresense = with types; {
    room = mkOption {
      type = attrsOf (submoduleWith {
        modules = [ espresenseRoomModule ];
        inherit (config.lib) specialArgs;
      });
      default = { };
    };
    device = mkOption {
      type = attrsOf (submoduleWith {
        modules = [ espresenseDeviceSettingsModule ];
        inherit (config.lib) specialArgs;
      });
      default = { };
    };
    roomSettings = mkOption {
      type = attrsOf json.data;
      default = { };
    };
    mqtt = {
      baseTopic = mkOption {
        type = str;
        default = "espresense";
      };
      settings = mkOption {
        type = attrsOf espresenseMqttType;
        default = { };
      };
      publish = mkOption {
        type = attrsOf str;
      };
    };
  };
  config = {
    espresense = {
      device = mapAttrs (_: room: {
        hass.enable = false;
        settings = {
          id = "node:${room.object_id}";
          name = mkDefault room.object_id.name;
        };
        ibeacon = mkDefault room.ibeacon;
      }) cfg.room;
      roomSettings = {
        known_macs = mapAttrsToList (_: dev: mkIf dev.bt.known dev.bt.macId) cfg.device;
        known_irks = mapAttrsToList (_: dev: mkIf (dev.bt.irk != null) dev.bt.irk) cfg.device;
      };
      mqtt = {
        settings = mkMerge (
          mapAttrsToList (_: room: mapAttrs' (key:
            nameValuePair "${cfg.mqtt.baseTopic}/rooms/${room.object_id}/${key}/set"
          ) room.settings) cfg.room
          ++ singleton (mapAttrs' (_: dev:
            nameValuePair "${cfg.mqtt.baseTopic}/settings/${dev.bt.device_id}/config" (builtins.toJSON dev.settings)
          ) (filterAttrs (_: dev: dev.bt.device_id != null && dev.settings != { }) cfg.device))
        );
        publish = mapAttrs (_: config.lib.espresense.mqttPayloadFor) cfg.mqtt.settings;
      };
    };
    lib = {
      espresense.formatFloat = { precision ? 2 }: value: let
        str = if isInt value then toString (value + 0.0) else toString value;
        parts = splitString "." str;
        num = head parts;
        frac = last parts;
      in "${num}.${substring 0 precision frac}";
      espresense.mqttPayloadFor = data:
        if data == true then "ON"
        else if data == false then "OFF"
        else if isFloat data then config.lib.espresense.formatFloat { } data
        else toString data;
      types = with types; {
        espresenseMqttType = oneOf [ int float bool str (listOf str) ];
      };
    };
  };
}
