{ config, types, lib, ... }: with lib; let
  entityExportModule = { entity, config, types, lib, ... }: with lib; {
    options = with types; {
      google_assistant = mkOption {
        type = nullOr (entityExportGoogleType entity);
        default = { };
      };
      homekit = mkOption {
        type = nullOr (entityExportHomekitType entity);
        default = { };
      };
    };
  };
  entityExportHomekitModule = { config, types, lib, ... }: with lib; {
    imports = [ types.settingsModule ];
    options = with types; {
      name = mkOption {
        type = nullOr str;
        default = null;
      };
      features = mkOption {
        type = listOf (enum [ "on_off" "play_pause" "play_stop" "toggle_mute" ]);
        default = [ ];
      };
    };
    config = {
      settingsConfig = {
        nullableKeys = [ "name" ];
        ignoreKeys = [ "features" ];
      };
      settings = {
        feature_list = mkIf (config.features != [ ]) (map (feature: { inherit feature; }) config.features);
      };
    };
  };
  entityExportGoogleModule = { config, types, lib, ... }: with lib; {
    imports = [ types.settingsModule ];
    options = with types; {
      area = mkOption {
        type = nullOr (hassRef "area");
        default = null;
      };
      room = mkOption {
        type = nullOr str;
        default = if config.hidden
          then "XYZ"
          else mapNullable (area: (area.get { }).friendly_name) config.area;
      };
      hidden = mkOption {
        type = bool;
        default = false;
      };
    };
    config = {
      settingsConfig.ignoreKeys = [ "hidden" "area" ];
    };
  };
  entityCreateModule = { domain, meta, entity, config, types, lib, ... }: with lib; {
    imports = [ types.settingsModule ];
    freeformType = types.json.lazyAttrs;
    options = with types; {
      platform = mkOption {
        type = hassRef "platform";
      };
    };
    config = let
      domainPlatform = meta.platform.${domain} or null;
    in {
      settingsConfig = {
        settingsKeys = [ ];
      };
      platform = mkIf (domain != null && (domainPlatform.packageKey or null == domain || domainPlatform.domain or [ ] == [ domain ])) (
        # provide a default if it's unambiguous
        mkOptionDefault domain
      );
      settings = (config.platform.get { }).make entity config.settingsConfig.settings;
    };
  };
  entityModule = { meta, name, config, types, lib, ... }: with lib; {
    options = with types; {
      create = mkOption {
        type = nullOr (entityCreateType config);
        default = null;
      };
      export = mkOption {
        type = nullOr (entityExportType config);
        default = null;
      };
    };
    config = let
      createPlatform = config.create.platform or null;
      platform = meta.platform.${createPlatform.object_id or createPlatform} or (throw "platform.${createPlatform} does not exist");
      object_id = platform.get.object_id config.create;
      unique_id = platform.get.unique_id config.create;
      name = platform.get.name config.create;
      friendly_name = platform.get.friendly_name config.create;
    in {
      object_id = mkMerge [
        (mkIf (createPlatform != null && object_id != null) (mkOverride 950 object_id))
        (mkIf (createPlatform != null && name != null) (mkOverride 950 name))
      ];
      friendly_name = mkIf (createPlatform != null && friendly_name != null) (mkDefault friendly_name);
      unique_id = mkIf (createPlatform != null && unique_id != null) (mkDefault unique_id);
      _module.args = {
        inherit (config) domain;
      };
      assertions = [
        {
          assertion = createPlatform == null || name == null || name == toString config.object_id.name;
          message = "${config.domain}.${config.object_id} has mismatched create name: ${toString name} != ${config.object_id.name}";
        }
      ];
    };
  };
  entityDomains = filterAttrs (_: domain: domain.entity.enable) config.domain;
in {
  options = {
    entities = with types; mapAttrs (_: domain: mkOption {
      type = with types; hassAttrs {
        domain = domain.name;
        inherit (domain) freeform modules;
      };
      default = { };
    }) entityDomains;
  };
  imports = map (domain: mkRenamedOptionModule [ domain ] [ "entities" domain ]) (lib.entityDomains);
  config = let
  entityNamesAuto = attrNames (filterAttrs (_: domain: domain.entity.enable && !domain.entity.manual) config.domain);
    autoEntities = getAttrs entityNamesAuto config.entities;
    allEntities = getAttrs (attrNames entityDomains) config.entities;
    createEntities = filter (entity: entity.create.platform.object_id or null != null) (entitiesToList autoEntities);
    platformKey = platform: domain: unlessNull platform.packageKey domain;
    platformBundle = platform: domain: value: {
      "${platformKey platform domain}" = value;
    };
    platformEntities = let
      forEntity = platform: entity: platformBundle platform entity.domain (platform.apply entity);
    in mkMerge (map (entity: forEntity (entity.create.platform.get { }) entity) createEntities);
    /*platforms = attrValues config.platform;
    platformEntities = mkMerge platformEntities';
    groupByPlatform = groupBy (entity: toString entity.create.platform or null);
    entitiesForPlatform = mapAttrs (domain: entities: groupByPlatform (attrValues entities)) (getAttrs createDomains config.entities);
    platformEntities' = concatMap (platform: let
      mapPlatformDomain = domain: let
        #myEntities = filter (entity: entity.create.platform.object_id or null == platform.name) (attrValues config.entities.${domain});
        myEntities = entitiesForPlatform.${domain}.${platform.name} or [ ];
      in platformBundle platform domain (mkIf (myEntities != [ ]) (mkMerge (map platform.apply myEntities)));
    in map mapPlatformDomain platform.domain) platforms;
    createDomains = uniqueStrings (concatLists (catAttrs "domain" platforms));*/

    exports'google = filterEntities (entity: entity.export.google_assistant or null != null) allEntities;
    exports'apple = filterEntities (entity: entity.export.homekit or null != null) allEntities;
  in {
    package = {
      manual = mkMerge [ {
        homeassistant = {
          customize = mapListToAttrs (entity: nameValuePair "${entity}" entity.customize)
            (filter (entity: entity.customize or { } != { }) (entitiesToList allEntities));
        };
        google_assistant = {
          exposed_domains = mkIf false [ ]; # TODO
          entity_config = listToAttrs (mapEntitiesToList (entity: nameValuePair "${entity}" entity.export.google_assistant.settings) exports'google);
        };
      } platformEntities ];
      homekit = {
        # TODO: homekit integration can't deal with merging configs :<
        filter = {
          include_domains = mkIf false [ ]; # TODO: google_assistant.exposed_domains
          include_entities = mapEntitiesToList toString exports'apple;
        };
        entity_config = listToAttrs (mapEntitiesToList (entity: nameValuePair "${entity}" entity.export.homekit.settings) exports'apple);
      };
    };
    domain = genAttrs lib.entityDomains (domain: {
      entity.enable = true;
    });
    lib.types = with types; {
      inherit entityModule entityCreateModule;
      entityCreateType = entity: submoduleWith {
        modules = [
          entityCreateModule
        ];
        specialArgs = config.lib.specialArgs // {
          inherit entity;
          inherit (entity) domain;
        };
      };
      entityExportType = entity: submoduleWith {
        modules = [
          entityExportModule
        ];
        specialArgs = config.lib.specialArgs // {
          inherit entity;
        };
      };
      entityExportHomekitType = entity: submoduleWith {
        modules = [
          entityExportHomekitModule
        ];
        specialArgs = config.lib.specialArgs // {
          inherit entity;
        };
      };
      entityExportGoogleType = entity: submoduleWith {
        modules = [
          entityExportGoogleModule
          ({ entity, ... }: {
            config.area = mkDefault entity.area;
          })
        ];
        specialArgs = config.lib.specialArgs // {
          inherit entity;
        };
      };
    };
    lib.specialArgs = {
      entities = let
        mapEntity = entity: nameValuePair "${entity.object_id}" entity;
      in mapAttrs (domain: mapAttrs' (_: mapEntity)) allEntities // {
        device = mapAttrs (_: d: d // d.entities) config.device;
      };
      hass = config.lib.specialArgs.entities;
    };
    assertions = mkMerge (mapEntitiesToList (entity: entity.assertions) allEntities);
  };
}
