{ config, types, lib, ... }: with lib; let
  platforms = {
    templated = {
      object_id = "template";
      domain = [ "binary_sensor" "sensor" "number" "select" "button" ];
      apply = entity: let
        settings = removeAttrs entity.create.settings [ "trigger" ];
      in singleton ({
        "${entity.domain}" = singleton settings;
      } // optionalAttrs (entity.create.settings.trigger or null != null) {
        inherit (entity.create.settings) trigger;
      });
      packageKey = "template";
    };
    template = let
      domainKey = domain: {
        switch = "switches";
        binary_sensor = "sensors";
        alarm_control_panel = "panels";
        lock = null;
        weather = null;
      }.${domain} or "${domain}s";
    in {
      # legacy format: https://www.home-assistant.io/integrations/template/#legacy-sensor-configuration-format
      domain = [ "binary_sensor" "sensor" "alarm_control_panel" "cover" "fan" "light" "switch" "vacuum" "lock" "weather" ];
      get.object_id = { object_id ? null, ... }: object_id;
      make = entity: create: let
        key = domainKey entity.domain;
      in if key == null
        then create // {
          platform = "template";
        } else {
          platform = "template";
          ${domainKey entity.domain} = {
            "${create.object_id or entity.object_id}" = removeAttrs create [ "name" "platform" ] // {
              ${if create ? name then "friendly_name" else null} = create.friendly_name or create.name;
            };
          };
        };
    };
    person = {
      packageKey = "person";
    };
    zone = {
      packageKey = "zone";
    };
    timer = {
      packageKey = "timer";
    };
    tag = {
      domain = [ "tag" ];
      # yaml tag management isn't actually supported :<
      apply = _: {};
    };
    alert.entityAttrs.enable = true;
    input_boolean.entityAttrs.enable = true;
    input_select.entityAttrs.enable = true;
    mqtt = {
      domain = [
        "binary_sensor" "sensor" "camera" "device_tracker"
        "alarm_control_panel" "button" "cover" "light" "lock" "switch" "scene"
        # "device_trigger" "tag"
        "fan" "humidifier" "climate" "vacuum"
        "number" "select" "text"
        "siren" "update"
      ];
      get.object_id = { object_id ? null, ... }: object_id;
      apply = entity: {
        "${entity.domain}" = singleton entity.create.settings;
      };
      packageKey = "mqtt";
    };
    group = {
      domain = [ "binary_sensor" "light" "switch" "cover" "fan" "lock" "media_player" "sensor" "notify" ];
    };
    mjpeg = {
      domain = [ "camera" ];
    };
    flux = {
      domain = [ "switch" ];
    };
    generic_thermostat = {
      domain = [ "climate" ];
    };
    bayesian = {
      domain = [ "binary_sensor" ];
    };
    mqtt_room = {
      domain = [ "sensor" ];
    };
    powercalc = {
      domain = [ "sensor" ];
    };
    derivative = {
      domain = [ "sensor" ];
    };
    statistics = {
      domain = [ "sensor" ];
    };
    threshold = {
      domain = [ "binary_sensor" ];
    };
    history_stats = {
      domain = [ "sensor" ];
    };
  };
  switchPlatforms = let
    turn_on' = { entity_id, domain ? entity_id.domain, ... }: act.service "${domain}.turn_on" {
      inherit entity_id;
    };
    turn_off' = { entity_id, domain ? entity_id.domain, ... }: act.service "${domain}.turn_off" {
      inherit entity_id;
    };
    turn_on = { invert ? false, entity_id, ... }@create: if invert then turn_off' create else turn_on' create;
    turn_off = { invert ? false, entity_id, ... }@create: if invert then turn_on' create else turn_off' create;
    value_template_bool = { invert ? false, entity_id, ... }: if invert
      then "{{ is_state('${entity_id}', 'off') }}"
      else "{{ is_state('${entity_id}', 'on') }}";
    value_template' = { entity_id, ... }: on: off:
      "{{ '${on}' if is_state('${entity_id}', '${if invert then "on" else "off"}') else '${off}' }}";
    value_template = { invert ? false, entity_id, ... }@create: if invert
      then value_template' create "on" "off"
      else "{{ states('${entity_id}') }}";
    entityTemplate = create: {
      friendly_name = create.name;
    } // retainAttrs create [
      "unique_id" "device_class"
      "value_template" "icon_template" "entity_picture_template" "availability_template"
    ];
  in {
    switch2cover = {
      object_id = "template";
      domain = [ "cover" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          value_template = value_template_bool;
          open_cover = turn_on;
          close_cover = turn_off;
        };
      in config.platform.template.make entity templated;
      inherit (config.platform.template) get;
    };
    switch2light = {
      object_id = "template";
      domain = [ "light" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          inherit value_template;
        };
      in config.platform.template.make entity templated;
      inherit (config.platform.template) get;
    };
    switch2fan = {
      object_id = "template";
      domain = [ "fan" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          inherit value_template turn_on turn_off;
        } // {
          speed_count = 1;
        };
      in config.platform.template.make entity templated;
      inherit (config.platform.template) get;
    };
    switch2switch = {
      inherit (config.platform.template) get; # object_id?
      object_id = "template";
      domain = [ "switch" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          value_template = value_template_bool;
          inherit turn_on turn_off;
        };
      in config.platform.template.make entity templated;
    };
    light2switch = {
      object_id = "template";
      domain = [ "switch" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          value_template = value_template_bool;
          inherit turn_on turn_off;
        };
      in config.platform.template.make entity templated;
      inherit (config.platform.template) get;
    };
    switch2binary_sensor = {
      object_id = "template";
      domain = [ "binary_sensor" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          state = value_template;
        };
      in config.platform.template.make entity templated;
      inherit (config.platform.templated) get apply packageKey;
    };
    switch2button = {
      object_id = "template";
      domain = [ "button" ];
      make = entity: create: let
        templated = entityTemplate create // mapAttrs (_: f: f create) {
          press = turn_on;
        };
      in config.platform.template.make entity templated;
      inherit (config.platform.templated) get apply packageKey;
    };
    switch = {
      domain = [ "light" ];
      make = _: flip retainAttrs [ "entity_id" "name" "platform" ];
    };
    switch_as_x = {
      domain = [ "light" ];
      make = unimplemented;
    };
  };
in {
  config.platform = mkMerge [ platforms switchPlatforms ];
}
