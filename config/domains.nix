{ lib, ... }: with lib; let
in {
  light = {
    services = {
      turn_on = {
        mkData = {
          entity_id
        , transition ? null
        , profile ? null
        , hs_color ? null
        , xy_color ? null
        , rgb_color ? null
        , rgbw_color ? null
        , rgbww_color ? null
        , color_temp ? null
        , kelvin ? null
        , color_name ? null
        , brightness ? null
        , brightness_pct ? null
        , brightness_step ? null
        , brightness_step_pct ? null
        , white ? null
        , flash ? null # "short", "long"
        , effect ? null
        }@args: args;
        shorthand = "entity_id";
      };
      turn_off = {
        mkData = {
          entity_id
        , transition ? null
        }@args: args;
        shorthand = "entity_id";
      };
      toggle = light.services.turn_on;
    };
  };
  switch = {
    services = {
      turn_on = {
        mkData = {
          entity_id
        }@args: args;
        shorthand = "entity_id";
      };
      turn_off = switch.services.turn_on;
      toggle = switch.services.turn_on;
    };
  };
  button = {
    services = {
      press = {
        mkData = {
          entity_id
        }@args: args;
        shorthand = "entity_id";
      };
    };
    classes = {
       restart = { };
       update = { };
    };
  };
  number = {
    services = {
      set_value = {
        mkData = {
          value
        , entity_id ? null
        , area_id ? null
        , entity_ids ? null, area_ids ? null
        }@args: args;
        shorthand = entity_id: value: {
          inherit entity_id value;
        };
      };
    };
  };
  select = {
    services = {
      select_option = {
        mkData = {
          option
        , entity_id ? null
        , area_id ? null
        , entity_ids ? null, area_ids ? null
        }@args: args;
        shorthand = entity_id: option: {
          inherit entity_id option;
        };
      };
    };
  };
  timer = {
    services = {
      start = {
        mkData = {
          entity_id
        , duration ? null
        }@args: args;
        shorthand = "entity_id";
      };
      pause = {
        mkData = {
          entity_id
        }@args: args;
        shorthand = "entity_id";
      };
      cancel = {
        mkData = {
          entity_id
        }@args: args;
        shorthand = "entity_id";
      };
      finish = {
        mkData = {
          entity_id
        }@args: args;
        shorthand = "entity_id";
      };
      reload = {
        mkData = { }@args: args;
        shorthand = {};
      };
    };
    events = {
      cancelled = { };
      finished = { };
      started = { };
      restarted = { };
      paused = { };
    };
  };
  tag = {
    events = {
      scanned = { };
    };
  };
  weather = { };
  sun = { };
  calendar = { };
  update = { };
  device_automation = { };
  cover = {
    services = rec {
      open_cover = {
        mkData = {
          entity_id ? "all"
        }@args: args;
        shorthand = "entity_id";
      };
      set_cover_position = {
        mkData = {
          entity_id ? "all"
        , position # 0 to 100
        }@args: args;
        shorthand = entity_id: position: {
          inherit entity_id position;
        };
      };
      close_cover = open_cover;
      stop_cover = open_cover;
      toggle = open_cover;
      open_cover_tilt = open_cover;
      close_cover_tilt = open_cover;
      stop_cover_tilt = open_cover;
      toggle_tilt = open_cover;
    };
    classes = {
      awning = { };
      blind = { };
      curtain = { };
      damper = { };
      door = { };
      garage = { };
      gate = { };
      shade = { };
      shutter = { };
      window = { };
    };
  };
  lock = {
    services = rec {
      lock = {
        mkData = {
          entity_id
        }@args: args;
        shorthand = "entity_id";
      };
      unlock = lock;
      open = lock;
    };
  };
  siren = {
    services = rec {
      turn_on = {
        mkData = {
          entity_id ? "all"
        , tone ? null
        , duration ? null # integer
        , volume_level ? null # float 0 to 1
        }@args: args;
        shorthand = "entity_id";
      };
      turn_off = {
        mkData = {
          entity_id ? "all"
        }@args: args;
        shorthand = "entity_id";
      };
      toggle = turn_off;
    };
  };
  sensor = {
    classes = {
      apparent_power = { };
      aqi = { };
      battery = { };
      carbon_dioxide = { };
      carbon_monoxide = { };
      current = { };
      date = { };
      distance = { };
      duration = { };
      energy = { };
      frequency = { };
      gas = { };
      humidity = { };
      illuminance = { };
      moisture = { };
      monetary = { };
      nitrogen_dioxide = { };
      nitrogen_monoxide = { };
      nitrous_oxide = { };
      ozone = { };
      pm1 = { };
      pm10 = { };
      pm25 = { };
      power_factor = { };
      power = { };
      pressure = { };
      reactive_power = { };
      signal_strength = { };
      speed = { };
      sulphur_dioxide = { };
      temperature = { };
      timestamp = { };
      volatile_organic_compounds = { };
      voltage = { };
      volume = { };
      weight = { };
    };
  };
  binary_sensor = {
    classes = {
      battery = { };
      battery_charging = { };
      carbon_monoxide = { };
      cold = { };
      connectivity = { };
      door = { };
      garage_door = { };
      gas = { };
      heat = { };
      light = { };
      lock = { };
      moisture = { };
      motion = { };
      moving = { };
      occupancy = { };
      opening = { };
      plug = { };
      power = { };
      presence = { };
      problem = { };
      running = { };
      safety = { };
      smoke = { };
      sound = { };
      tamper = { };
      update = { };
      vibration = { };
      window = { };
    };
  };
  fan = {
    services = {
      set_percentage = {
        mkData = {
          entity_id ? "all"
        , percentage
        }@args: args;
        shorthand = entity_id: percentage: {
          inherit entity_id percentage;
        };
      };
      set_preset_mode = {
        mkData = {
          entity_id ? "all"
        , preset_mode
        }@args: args;
        shorthand = entity_id: preset_mode: {
          inherit entity_id preset_mode;
        };
      };
      set_direction = {
        mkData = {
          entity_id ? "all"
        , direction
        }@args: args;
        shorthand = entity_id: direction: {
          inherit entity_id direction;
        };
      };
      oscillate = {
        mkData = {
          entity_id ? "all"
        , oscillating
        }@args: args;
        shorthand = entity_id: oscillating: {
          inherit entity_id oscillating;
        };
      };
      turn_on = {
        mkData = {
          entity_id ? "all"
        , percentage ? null
        , preset_mode ? null
        }@args: args;
        shorthand = "entity_id";
      };
      turn_off = {
        mkData = {
          entity_id ? "all"
        }@args: args;
        shorthand = "entity_id";
      };
      toggle = turn_off;
      increase_speed = {
        mkData = {
          entity_id ? "all"
        , percentage_step ? null # 0 to 100
        }@args: args;
        shorthand = entity_id: percentage_step: {
          inherit entity_id percentage_step;
        };
      };
      decrease_speed = increase_speed;
      set_speed = {
        mkData = {
          entity_id ? "all"
        , speed
        }@args: warn "fan.set_speed is deprecated" args;
      };
    };
  };
  climate = {
    services = rec {
      set_aux_heat = {
        mkData = {
          entity_id ? "all"
        , aux_heat
        }@args: args;
        shorthand = entity_id: aux_heat: {
          inherit entity_id aux_heat;
        };
      };
      set_preset_mode = {
        mkData = {
          entity_id ? "all"
        , preset_mode
        }@args: args;
        shorthand = entity_id: preset_mode: {
          inherit entity_id preset_mode;
        };
      };
      set_temperature = {
        mkData = {
          entity_id ? "all"
        , temperature ? null
        , target_temp_high ? null
        , target_temp_low ? null
        , hvac_mode ? null
        }@args: args;
        shorthand = entity_id: temperature: {
          inherit entity_id temperature;
        };
      };
      set_humidity = {
        mkData = {
          entity_id ? "all"
        , humidity
        }@args: args;
        shorthand = entity_id: humidity: {
          inherit entity_id humidity;
        };
      };
      set_fan_mode = {
        mkData = {
          entity_id ? "all"
        , fan_mode
        }@args: args;
        shorthand = entity_id: fan_mode: {
          inherit entity_id fan_mode;
        };
      };
      set_hvac_mode = {
        mkData = {
          entity_id ? "all"
        , hvac_mode
        }@args: args;
        shorthand = entity_id: hvac_mode: {
          inherit entity_id hvac_mode;
        };
      };
      set_swing_mode = {
        mkData = {
          entity_id ? "all"
        , swing_mode
        }@args: args;
        shorthand = entity_id: swing_mode: {
          inherit entity_id swing_mode;
        };
      };
      turn_on = {
        mkData = {
          entity_id ? "all"
        }@args: args;
        shorthand = "entity_id";
      };
      turn_off = turn_on;
    };
    entity.attributes = {
      hvac_action = {
        options = [ "idle" "heating" "cooling" ];
      };
      fan = {
        options = [ on off ];
      };
    };
  };
  water_heater = {
  };
  humidifier = {
  };
  vacuum = {
  };
  media_player = {
    services = rec {
      turn_on = {
        mkData = { entity_id ? "all" }@args: args;
        shorthand = "entity_id";
      };
      turn_off = turn_on;
      toggle = turn_on;
      volume_up = turn_on;
      volume_down = turn_on;
      volume_set = {
        mkData = {
          volume_level
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: volume_level: {
          inherit entity_id volume_level;
        };
      };
      volume_mute = {
        mkData = {
          is_volume_muted
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: is_volume_muted: {
          inherit entity_id is_volume_muted;
        };
      };
      media_play_pause = turn_on;
      media_play = turn_on;
      media_pause = turn_on;
      media_stop = turn_on;
      media_next_track = turn_on;
      media_previous_track = turn_on;
      media_seek = {
        mkData = {
          seek_position
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: seek_position: {
          inherit entity_id seek_position;
        };
      };
      clear_playlist = turn_on;
      shuffle_set = {
        mkData = {
          shuffle
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: shuffle: {
          inherit entity_id shuffle;
        };
      };
      repeat_set = {
        mkData = {
          repeat
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: repeat: {
          inherit entity_id repeat;
        };
      };
      play_media = {
        mkData = {
          media_content_type
        , media_content_id
        , entity_id ? "all"
        , enqueue ? "replace" # "add", "next", "play", "replace"
        , announce ? false
        , extra ? {
          title = null;
          thumb = null; # url
          current_time = null; # float
          autoplay = true;
          stream_type = null; # "NONE", "BUFFERED", "LIVE"
          subtitles = null; # url
          subtitles_lang = null;
          subtitles_mime = null;
          subtitle_id = null; # int
          enqueue = false;
          media_info = { };
          metadata = { };
        } }@args: args;
        shorthand = entity_id: media_content_type: media_content_id: {
          inherit entity_id media_content_type media_content_id;
        };
      };
      select_source = {
        mkData = {
          source
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: source: {
          inherit entity_id source;
        };
      };
      select_sound_mode = {
        mkData = {
          sound_mode
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: sound_mode: {
          inherit entity_id sound_mode;
        };
      };
      join = {
        mkData = {
          group_members # player entities to be sync'd
        , entity_id ? "all"
        }@args: args;
        shorthand = entity_id: group_members: {
          inherit entity_id group_members;
        };
      };
      unjoin = turn_on;
    };
  };
  device_tracker = {
    services = {
      see = {
        mkData = {
          dev_id
        , location_name ? null # "home", "not_home", or a zone
        , host_name ? null
        , mac ? null
        , gps ? null
        , gps_accuracy ? null
        , battery ? null
        }@args: args;
      };
    };
  };
  person = { };
  zone = { };
  camera = {
  };
  remote = {
  };
  alarm_control_panel = {
  };
  cast = {
    services = {
      show_lovelace_view = {
        mkData = {
          entity_id
        , dashboard_path ? null
        , view_path ? null
        }@args: args;
      };
    };
  };
  notify = {
    services = {
      notify = {
        mkData = {
          message
        , title ? null
        , target ? null
        , data ? null
        }@args: args;
      };
      persistent_notification = {
        mkData = {
          message
        , title ? null
        , target ? null
        , data ? null
        }@args: args;
      };
    };
  };
  persistent_notification = {
    services = {
      create = {
        mkData = {
          message
        , title ? null
        , notification_id ? null
        }@args: args;
      };
      dismiss = {
        mkData = { notification_id }@args: args;
        shorthand = "notification_id";
      };
    };
  };
  alert = {
  };
  input_boolean = {
  };
  input_select = {
  };
  text = {
  };
}
