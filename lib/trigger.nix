{ lib, hass-lib }: let
  inherit (lib) isAttrs;
  inherit (hass-lib) trigger;
  deviceTrigger = device: type: args: device type args;
in {
  state = {
    entity_id
  , attribute ? null
  , to ? null
  , not_to ? null
  , from ? null
  , not_from ? null
  , for ? { hours = 0; minutes = 0; seconds = 0; }
  , id ? null, enabled ? true
  }@args: args // {
    platform = "state";
  };
  numeric_state = {
    entity_id
  , attribute ? null
  , value_template ? null
  , above ? null
  , below ? null
  , for ? { hours = 0; minutes = 0; seconds = 0; }
  , id ? null, enabled ? true
  }@args: args // {
    platform = "numeric_state";
  };
  event = event_type: event_data: trigger.event' {
    inherit event_type event_data;
  };
  event' = {
    event_type
  , event_data ? {}
  , context ? {}
  , id ? null, enabled ? true
  }@args: args // {
    platform = "event";
  };
  homeassistant = event: {
    platform = "homeassistant";
    inherit event;
  };
  mqtt = {
    topic
  , payload ? null
  , value_template ? null
  , encoding ? null
  , id ? null, enabled ? true
  }@args: args // {
    platform = "mqtt";
  };
  sun = {
    event
  , offset ? null
  , id ? null, enabled ? true
  }@args: args // {
    platform = "sun";
  };
  tag = {
    tag_id
  , device_id ? null
  , id ? null, enabled ? true
  }@args: args // {
    platform = "tag";
  };
  template = value_template: if isAttrs value_template
    then trigger.template' value_template
    else {
      platform = "template";
      inherit value_template;
    };
  template' = {
    value_template
  , for ? { hours = 0; minutes = 0; seconds = 0; }
  , id ? null, enabled ? true
  }@args: args // {
    platform = "template";
  };
  time = at: {
    platform = "time";
    inherit at;
  };
  time_pattern = {
    minutes ? null
  , hours ? null
  , id ? null, enabled ? true
  }@args: args // {
    platform = "time_pattern";
  };
  webhook = webhook_id: {
    platform = "webhook";
    inherit webhook_id;
  };
  zone = {
    entity_id
  , zone
  , event
  , id ? null, enabled ? true
  }@args: args // {
    platform = "zone";
  };
  location = {
    source
  , zone
  , event
  , id ? null, enabled ? true
  }@args: args // {
    platform = "geo_location";
  };
  calendar = {
    entity_id
  , event
  , offset ? null
  , id ? null, enabled ? true
  }@args: args // {
    platform = "calendar";
  };
  device = {
    mqtt = {
      action = {
        device_id
      , subtype
      , discovery_id ? if unique_id != null then "${unique_id} action_${subtype}" else throw "missing mqtt unique_id for ${device_id}.action_${subtype}"
      , unique_id ? null # 0x....
      , id ? null, enabled ? true
      }@args: removeAttrs args [ "unique_id" ] // {
        platform = "device";
        domain = "mqtt";
        type = "action";
        inherit discovery_id;
      };
    };
    select = {
      current_option_changed = deviceTrigger "current_option_changed" trigger.device.select;
      __functor = _: type: {
        device_id
      , entity_id
      , from ? null, to ? null
      , for ? { hours = 0; minutes = 0; seconds = 0; }
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "select";
        inherit type;
      };
    };
    switch = {
      changed_states = deviceTrigger "changed_states" trigger.device.switch;
      turned_off = deviceTrigger "turned_off" trigger.device.switch;
      turned_on = deviceTrigger "turned_on" trigger.device.switch;
      __functor = _: type: {
        device_id
      , entity_id
      , for ? { hours = 0; minutes = 0; seconds = 0; }
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "switch";
        inherit type;
      };
    };
    binary_sensor = {
      update = deviceTrigger "update" trigger.device.binary_sensor;
      no_update = deviceTrigger "no_update" trigger.device.binary_sensor;
      problem = deviceTrigger "problem" trigger.device.binary_sensor;
      no_problem = deviceTrigger "no_problem" trigger.device.binary_sensor;
      connected = deviceTrigger "connected" trigger.device.binary_sensor;
      not_connected = deviceTrigger "not_connected" trigger.device.binary_sensor;
      plugged_in = deviceTrigger "plugged_in" trigger.device.binary_sensor;
      not_plugged_in = deviceTrigger "not_plugged_in" trigger.device.binary_sensor;
      turned_on = deviceTrigger "turned_on" trigger.device.binary_sensor;
      turned_off = deviceTrigger "turned_off" trigger.device.binary_sensor;
      __functor = _: type: {
        device_id
      , entity_id
      , for ? { hours = 0; minutes = 0; seconds = 0; }
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "binary_sensor";
        inherit type;
      };
    };
    button = {
      pressed = deviceTrigger "update" trigger.device.button;
      __functor = _: type: {
        device_id
      , entity_id
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "button";
        inherit type;
      };
    };
    sensor = {
      value = deviceTrigger "value" trigger.device.sensor;
      energy = deviceTrigger "energy" trigger.device.sensor;
      power = deviceTrigger "power" trigger.device.sensor;
      battery_level = deviceTrigger "battery_level" trigger.device.sensor;
      signal_strength = deviceTrigger "signal_strength" trigger.device.sensor;
      illuminance = deviceTrigger "illuminance" trigger.device.sensor;
      pressure = deviceTrigger "pressure" trigger.device.sensor;
      temperature = deviceTrigger "temperature" trigger.device.sensor;
      humidity = deviceTrigger "humidity" trigger.device.sensor;
      carbon_dioxide = deviceTrigger "carbon_dioxide" trigger.device.sensor;
      volatile_organic_compounds = deviceTrigger "volatile_organic_compounds" trigger.device.sensor;
      voltage = deviceTrigger "voltage" trigger.device.sensor;
      current = deviceTrigger "current" trigger.device.sensor;
      __functor = _: type: {
        device_id
      , entity_id
      , above ? null, below ? null
      , for ? { hours = 0; minutes = 0; seconds = 0; }
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "sensor";
        inherit type;
      };
    };
    light = {
      changed_states = deviceTrigger trigger.device.light "changed_states";
      turned_off = deviceTrigger trigger.device.light "turned_off";
      turned_on = deviceTrigger trigger.device.light "turned_on";
      __functor = _: type: {
        device_id
      , entity_id
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "light";
        inherit type;
      };
    };
    media_player = {
      changed_states = deviceTrigger trigger.device.media_player "changed_states";
      turned_off = deviceTrigger trigger.device.media_player "turned_off";
      turned_on = deviceTrigger trigger.device.media_player "turned_on";
      idle = deviceTrigger trigger.device.media_player "idle";
      buffering = deviceTrigger trigger.device.media_player "buffering";
      playing = deviceTrigger trigger.device.media_player "playing";
      paused = deviceTrigger trigger.device.media_player "paused";
      __functor = _: type: {
        device_id
      , entity_id
      , for ? { hours = 0; minutes = 0; seconds = 0; }
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "media_player";
        inherit type;
      };
    };
    climate = {
      hvac_mode_changed = deviceTrigger trigger.device.climate "hvac_mode_changed";
      temperature = deviceTrigger trigger.device.climate "temperature";
      current_temperature_changed = deviceTrigger trigger.device.climate "current_temperature_changed";
      __functor = _: type: {
        device_id
      , entity_id
      , above ? null, below ? null
      , for ? { hours = 0; minutes = 0; seconds = 0; }
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "climate";
        inherit type;
      };
    };
    device_tracker = {
      enters = deviceTrigger trigger.device.device_tracker "enters";
      leaves = deviceTrigger trigger.device.device_tracker "leaves";
      __functor = _: type: {
        device_id
      , entity_id
      , zone ? null
      , id ? null, enabled ? true
      }@args: args // {
        platform = "device";
        domain = "climate";
        inherit type;
      };
    };
  };
  scene = scene: trigger.event "call_service" {
    domain = "scene";
    service = "turn_on";
    service_data.entity_id = scene;
  };
}
