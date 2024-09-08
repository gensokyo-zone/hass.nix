let
  ibeaconIdModule = { config, types, lib, ... }: with lib; {
    options = with types; {
      id = mkOption {
        type = str;
        default = "${config.uuid}-${toString config.major}-${toString config.minor}";
      };
      uuid = mkOption {
        type = str;
        description = "uuidgen --sha1";
      };
      major = mkOption {
        type = int;
        default = 100;
      };
      minor = mkOption {
        type = int;
        default = 1;
      };
    };
  };
  eddystoneUidModule = { eddystone, options, config, types, lib, ... }: with lib; {
    options = with types; {
      namespace = {
        uuid = mkOption {
          type = str;
        };
        id = mkOption {
          type = nullOr str;
          default = null;
        };
        id0 = mkOption {
          type = nullOr str;
          default = mapNullable (id: eddystone.mkNamespaceIdSub { inherit id; suffix = "0"; }) config.namespace.id;
        };
        id1 = mkOption {
          type = nullOr str;
          default = mapNullable (id: eddystone.mkNamespaceIdSub { inherit id; suffix = "1"; }) config.namespace.id;
        };
      };
      instance = {
        id = mkOption {
          type = nullOr str;
          default = null;
        };
        major = mkOption {
          type = int;
        };
        minor = mkOption {
          type = int;
        };
      };
    };
    config = {
      instance.id = mkIf options.instance.minor.isDefined (
        eddystone.mkInstanceId { inherit (config.instance) major minor; }
      );
      namespace.id = mkIf options.namespace.uuid.isDefined (
        eddystone.mkNamespaceId { inherit (config.namespace) uuid; }
      );
    };
  };
  bluetoothBeaconManufacturerModule = { config, types, lib, ... }: with lib; {
    options = with types; {
      code = mkOption {
        type = nullOr (strMatching "[0-9a-f]{4}");
        default = null;
      };
      data = mkOption {
        type = nullOr (strMatching "([0-9a-f]{2})+");
        default = null;
      };
      dataLength = mkOption {
        type = int;
        default = stringLength (coalesce [ config.data "" ]) / 2;
      };
      apple = {
        id = mkOption {
          type = nullOr str;
          default = null;
        };
        model = mkOption {
          type = nullOr str;
          default = null;
        };
      };
      microsoft = {
        cdp = mkOption {
          type = nullOr str;
          default = null;
        };
      };
    };
  };
  bluetoothBeaconModule = { meta, eddystone, name, config, options, types, lib, ... }: with lib; {
    options = with types; {
      model = mkOption {
        type = nullOr (hassRef "model");
        default = null;
      };
      bt = {
        mac = mkOption {
          type = nullOr str;
          default = null;
        };
        irk = mkOption {
          type = nullOr str;
          default = null;
        };
        name = mkOption {
          type = nullOr str;
          default = null;
        };
        advertisement = {
          manufacturer = mkOption {
            type = submoduleWith {
              modules = [ bluetoothBeaconManufacturerModule ];
              inherit (meta.lib) specialArgs;
            };
            default = { };
          };
          service.uuid = {
            fingerprint = mkOption {
              type = nullOr str;
              default = null;
            };
          };
          service.data = {
            fingerprint = mkOption {
              type = nullOr str;
              default = null;
            };
            # TODO: COVID exposure (exp:)
          };
        };
      };
      roomAssistant = {
        id = mkOption {
          type = nullOr str;
          default = null;
        };
      };
      ibeacon = mkOption {
        type = nullOr ibeaconId;
        default = null;
      };
      eddystone = {
        id = mkOption {
          type = nullOr str;
          default = mapNullable (uid: "${uid.namespace.id}-${uid.instance.id}") config.eddystone.uid;
        };
        uid = mkOption {
          type = nullOr eddystoneUid;
          default = null;
        };
      };
    };
  };
  espresenseBeaconModule = { name, config, options, types, lib, ... }: with lib; let
    model = mapNullable (model: model.get { }) config.model;
  in {
    imports = [ bluetoothBeaconModule ];
    options = with types; {
      hass = {
        enable = mkEnableOption "home-assistant sensor" // {
          default = true;
        };
        user.enable = mkEnableOption "default room user";
        tracker = {
          enable = mkEnableOption "home-assistant device_tracker";
          announce = mkEnableOption "home-assistant tracker debug announcements";
        };
        timeout = mkOption {
          type = int;
          default = model.ble.espresense.timeout or 15;
        };
        away_timeout = mkOption {
          type = int;
          default = model.ble.espresense.away_timeout or (config.hass.timeout * 5);
        };
      };
      device_id = mkOption {
        type = nullOr espresenseDeviceId;
        default = bt.device_id;
      };
      bt = {
        device_id = mkOption {
          type = nullOr espresenseDeviceId;
          default = null;
        };
        known = mkEnableOption "known:mac";
        macId = mkOption {
          type = nullOr str;
          default = mapNullable (mac: replaceStrings [ ":" ] [ "" ] (toLower mac)) config.bt.mac;
        };
        factorySettings = mkOption {
          type = json.attrs;
          default = { };
        };
        beaconSettings = mkOption {
          type = json.attrs;
          default = { };
        };
      };
      eddystone = {
        enable = mkEnableOption "Eddystone" // {
          default = config.eddystone.uid.namespace.id or null != null && config.eddystone.id != null;
        };
        tlm = {
          enable = mkEnableOption "Eddystone Telemetry";
        };
      };
    };
    config = {
      #object_id = mkIf (config.bt.device_id != null) (mkDefault config.bt.device_id);
      device_id = mkIf (config.settings.id or null != null) (mkDefault config.settings.id);
      bt.device_id = let
        inherit (config) bt;
        mkOverrideId = prio: mkOverride (750 - prio);
      in mkMerge [
        (mkIf (bt.known && bt.mac != null) (mkOverrideId 210 "known:${bt.macId}"))
        (mkIf (bt.irk != null) (mkOverrideId 200 "irk:${bt.irk}"))
        (mkIf (config.ibeacon != null) (mkOverrideId 180 "iBeacon:${config.ibeacon.id}"))
        (mkIf config.eddystone.enable (mkOverrideId 170 "eddy:${config.eddystone.id}"))
        (mkIf (bt.name != null) (mkOverrideId 160 "name:${toLower bt.name}"))
        (mkIf (config.roomAssistant.id != null) (mkOverrideId 165 "roomAssistant:${config.roomAssistant.id}"))
        (mkIf (bt.advertisement.manufacturer.apple.model != null) (mkOverrideId 155 "apple:${bt.advertisement.manufacturer.apple.model}"))
        (mkIf (model.ble.espresense.macPrefix.service or null != null && bt.mac != null) (mkOverrideId 125 "${model.ble.espresense.macPrefix.service}:${bt.macId}"))
        (mkIf (model.ble.espresense.macPrefix.serviceData or null != null && bt.mac != null) (mkOverrideId 110 "${model.ble.espresense.macPrefix.serviceData}:${bt.macId}"))
        (mkIf (bt.advertisement.manufacturer.microsoft.cdp != null) (mkOverrideId 40 "msft:cdp:${bt.advertisement.manufacturer.microsoft.cdp}"))
        (mkIf (model.ble.espresense.macPrefix.manufacturer or null != null && bt.mac != null) (mkOverrideId 32 "${model.ble.espresense.macPrefix.manufacturer}:${bt.macId}"))
        (mkIf (bt.advertisement.manufacturer.apple.id != null) (mkOverrideId (-5) "apple:${bt.advertisement.manufacturer.apple.id}"))
        (mkIf (bt.mac != null) (mkOverrideId 55 bt.macId))
        (mkIf (bt.advertisement.manufacturer.code != null) (mkOverrideId 20 "md:${bt.advertisement.manufacturer.code}:${bt.advertisement.manufacturer.dataLength}"))
        (mkIf (bt.advertisement.service.data.fingerprint != null) (mkOverrideId 15 "sd:${bt.advertisement.service.data.fingerprint}"))
        (mkIf (bt.advertisement.service.uuid.fingerprint != null) (mkOverrideId 10 "ad:${config.bt.advertisement.service.uuid.fingerprint}"))
      ];
    };
  };
in { config, types, lib, ... }: with lib; {
  options = with types; {
    espresense.device = mkOption {
      type = attrsOf (submoduleWith {
        modules = [ espresenseBeaconModule ];
      });
    };
  };
  config = {
    lib = {
      types = with config.lib.types; {
        inherit ibeaconIdModule eddystoneUidModule bluetoothBeaconModule bluetoothBeaconManufacturerModule espresenseBeaconModule;
        ibeaconId = submoduleWith {
          modules = [ ibeaconIdModule ];
          inherit (config.lib) specialArgs;
        };
        eddystoneUid = submoduleWith {
          modules = [ eddystoneUidModule ];
          inherit (config.lib) specialArgs;
        };
        espresenseDeviceId = strMatching "([^:]+:)?.+";
      };
      beacon = {
        eddystone = {
          mkInstanceId = { major, minor }: fixedWidthNumber 6 (toHex major) + fixedWidthNumber 6 (toHex minor);
          mkNamespaceId = { uuid }: substring 0 8 uuid + substring 24 12 uuid;
          mkNamespaceIdSub = { id, suffix ? "0" }: substring 0 (20 - stringLength suffix) id + suffix;
          instances = {
            people = {
              major = 4096;
            };
          };
        };
      };
      specialArgs = {
        inherit (config.lib.beacon) eddystone;
      };
    };
  };
}
