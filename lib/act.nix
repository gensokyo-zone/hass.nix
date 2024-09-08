{ lib, hass-lib }: let
  inherit (lib) mapAttrs genAttrs isList toList;
  inherit (hass-lib) act cond trigger retainAttrs off;
  chooser = { conditions ? [ ], sequence, alias ? "" }@args: args // {
    conditions = toList conditions;
    sequence = toList sequence;
  };
in {
  service = {
    __functor = _: service: {
      target ? {}, entity_id ? null
    , data ? {}
    , alias ? "", enabled ? true, continue_on_error ? false
    , response_variable ? null
    }@args: args // {
      inherit service;
    };
  } // {
    script.turn_on_wait = let
      serviceAttrs = [ "data" "alias" "enabled" "continue_on_error" ];
    in entity_id: {
      data ? { }
    , alias ? "", enabled ? true, continue_on_error ? false
    , ...
    }@args: [
      # TODO: make this return a single action, even if it's a dumb no-op...
      (act.service "${entity_id}" ({
      } // retainAttrs args serviceAttrs))
      # TODO: only wait if on..?
      (act.wait_for_trigger.state ({
        entity_id = "${entity_id}";
        to = off;
      } // removeAttrs args serviceAttrs))
    ];
    # TODO: make this part of platforms module
    weather = {
      # https://www.home-assistant.io/integrations/weather/#action-weatherget_forecasts
      get_forecasts = {
        target ? {}, entity_id ? null
      , data ? {}, type # daily, twice_daily, hourly
      , alias ? "", enabled ? true, continue_on_error ? false
      , response_variable ? null
      }@args: act.service "weather.get_forecasts" (removeAttrs args [ "type" ] // {
        data = data // {
          inherit type;
        };
      });
    };
  } // genAttrs [
    # https://www.home-assistant.io/integrations/homeassistant#services
    "check_config" "reload_all" "reload_custom_templates" "reload_config_entry" "reload_core_config"
    "restart" "stop"
    "set_location"
    "toggle" "turn_on" "turn_off"
    "update_entity"
    "save_persistent_states"
  ] (service: act.service "homeassistant.${service}");
  scene = scene: {
    inherit scene;
  };
  variables = variables: {
    inherit variables;
  };
  delay = delay: {
    inherit delay;
  };
  wait_template = wait_template: act.wait_template' {
    inherit wait_template;
  };
  wait_template' = {
    wait_template
  , timeout ? null, continue_on_timeout ? true
  , alias ? "", enabled ? true, continue_on_error ? false
  }@args: args;
  wait_trigger = trigger: act.wait_for_trigger {
    inherit trigger;
  };
  wait_for_trigger = {
    __functor = _: {
      trigger
    , timeout ? null, continue_on_timeout ? true
    , alias ? "", enabled ? true, continue_on_error ? false
    }@args: removeAttrs args [ "trigger" ] // {
      wait_for_trigger = toList trigger;
    };
  } // mapAttrs (let
    waitAttrs = [ "trigger" "timeout" "continue_on_timeout" "alias" "enabled" "continue_on_error" ];
  in _: trigger: args: act.wait_for_trigger ({
    trigger = trigger (removeAttrs args waitAttrs);
  } // retainAttrs args waitAttrs)) trigger;
  event = event: event_data: {
    inherit event event_data;
  };
  repeat = count: sequence: {
    repeat = {
      inherit count;
      sequence = toList sequence;
    };
  };
  for_each = for_each: sequence: {
    repeat = {
      inherit for_each;
      sequence = toList sequence;
    };
  };
  while = while: sequence: {
    repeat = {
      inherit while;
      sequence = toList sequence;
    };
  };
  until = until: sequence: {
    repeat = {
      inherit until;
      sequence = toList sequence;
    };
  };
  if_then = if': then': else': {
    "if" = toList if';
    "then" = toList then';
    ${if else' == null then null else "else"} = toList else';
  };
  # TODO: if' = cond: { then, fallback ? null, alias ? null, args etc aaa }: etc
  choose = choose: default: {
    choose = map chooser (toList choose);
    ${if default == null then null else "default"} = toList default;
  };
  parallel = let
    mkParallel = action: if isList action then {
      sequence = action;
    } else action;
  in parallel: {
    parallel = map mkParallel parallel;
  };
  stop = stop: {
    inherit stop;
  };
  error = stop: {
    inherit stop;
    error = true;
  };
  # conditions can also be used as part of an action sequence to stop execution
  inherit cond;
}
