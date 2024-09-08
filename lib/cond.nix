{ lib, hass-lib }: let
  inherit (lib) isList toList;
  inherit (hass-lib) cond templated;
  utils = {
    false = cond.template templated.false;
  };
in {
  and = conditions: {
    condition = "and";
    conditions = toList conditions;
  };
  all = cond.and;
  or' = conditions: {
    condition = "or";
    conditions = toList conditions;
  };
  "or" = cond.or';
  any = cond.or';
  not = conditions: {
    condition = "not";
    conditions = toList conditions;
  };
  state = {
    entity_id
  , state, attribute ? null
  , match ? "all"
  , for ? { hours = 0; minutes = 0; seconds = 0; }
  , alias ? "", enabled ? true
  }@args: args // {
    condition = "state";
  };
  numeric_state = {
    entity_id
  , attribute ? null
  , above ? null, below ? null
  , value_template ? null
  , alias ? "", enabled ? true
  }@args: args // {
    condition = "numeric_state";
  };
  template = value_template: {
    condition = "template";
    inherit value_template;
  };
  time = {
    before ? null, after ? null
  , weekday ? [ ]
  , alias ? "", enabled ? true
  }@args: args // {
    condition = "time";
  };
  trigger = {
    id
  , alias ? "", enabled ? true
  }@args: args // {
    condition = "trigger";
  };
  zone = {
    entity_id
  , zone
  , alias ? "", enabled ? true
  }@args: removeAttrs args [ "zone" ] // {
    condition = "trigger";
    ${if isList zone then "state" else "zone"} = zone;
  };
} // utils
