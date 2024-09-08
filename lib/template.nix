{ lib, hass-lib }: let
  inherit (lib)
    optionalString concatStrings concatMapStringsSep
    isAttrs filterAttrs mapAttrs mapAttrsToList attrsToList
    removeSuffix removePrefix
    singleton
    isFunction functionArgs setFunctionArgs;
  inherit (hass-lib) template templated;
in {
  templated = let
    wrapF = wrap: f: setFunctionArgs (args: let
      res = f args;
    in if isFunction res then wrapF wrap res else wrap res) (functionArgs f);
    template' = mapAttrs (_: f: if isFunction f then wrapF templated.template f else templated.template f) template;
  in template' // {
    set_zone_distance = zone: entity: concatStrings [
      (templated.set "distance_km" "distance('${zone}', '${entity}')")
      (templated.set "distance_m" "distance_km * 1000 if distance_km is not None else None")
    ];
    zone_distance = zone: entity: concatStrings [
      (templated.set_zone_distance zone entity)
      (templated.template "distance_m")
    ];
    in_zone = zone: entity: concatStrings [
      (templated.set_zone_distance zone entity)
      (templated.template "distance_m <= state_attr('${zone}', 'radius') if distance_m is not None else false")
    ];
    set = key: value: "{% set ${key} = ${value} %}";
    template = value: "{{ ${template value} }}";
    untemplate = value: let
      inner = removeSuffix "}}" (removePrefix "{{" value);
    in removeSuffix " " (removePrefix " " inner);
    __functor = templated: templated.template;
  };
  template = let
    templateStrings = mapAttrs (_: template.string) {
      inherit (hass-lib) on off;
    };
  in templateStrings // {
    is_home = zones: entity: let
      home_zone_names = [ "home" ] ++ mapAttrsToList (_: zone: zone.friendly_name)
        (filterAttrs (_: zone: zone.is_home or false) zones);
    in "state('${entity}') in ${template.list (map template.string home_zone_names)}";
    timestamp_since = time: "as_timestamp(now()) - as_timestamp(${time})"; # seconds
    timestamp_since_updated = entity: template.timestamp_since "states.${entity}.last_updated"; # seconds
    timestamp_since_changed = entity: template.timestamp_since "states.${entity}.last_changed"; # seconds
    aqhi = { no2 ? "12.8", o3 ? "15", pm25 }: "1000 / 10.4 * (e ** (0.000537 * ${template o3}) - 1 + e ** (0.000871 * ${template no2}) - 1 + e ** (0.000487 * ${template pm25}) - 1)";
    state = entity: "states('${entity}')";
    attr = attr: entity: "state_attr('${entity}', '${attr}')";
    onoff = cond: "${template.on} if ${template cond} else ${template.off}";
    offon = cond: "${template.off} if ${template cond} else ${template.on}";
    list = values: "[${concatMapStringsSep ", " template values}]";
    dict = values: let
      values' = if isAttrs values then attrsToList values else values;
    in "{${concatMapStringsSep ", " ({ name, value }: template.dictNameValue name value) values'}}";
    dictNameValue = name: value: "${template.string name}: ${template value}";
    else_chain = conds: fallback: concatMapStringsSep " else " ({ value, cond }: "${template value}" + optionalString (cond != 42) " if ${template cond}") (conds ++ singleton { value = fallback; cond = 42; });
    string = v: "'${toString v}'";
    bool = v:
      if v == true then template.on
      else if v == false then template.off
      else throw "${toString v} is not a boolean";
    true = "True";
    false = "False";
    template = v:
      if builtins.isBool v then template.bool v
      else toString v;
    __functor = template: template.template;
  };
}
