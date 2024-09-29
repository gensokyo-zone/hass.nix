{ lib, hass-lib }: let
  inherit (lib)
    splitString substring stringLength replaceStrings toLower hasSuffix
    mod fixedWidthNumber
    attrValues recursiveUpdate filterAttrs mapAttrs mapAttrs' mapAttrsToList nameValuePair setAttrByPath
    isList concatMap concatLists elemAt length
    id isFunction functionArgs setFunctionArgs;
  inherit (hass-lib) nameid namedAs entityDomains mapEntitiesToList timeNorm getSettings on off groupedEntities;
in {
  parseRef = s: let
    parts = splitString "." (toString s);
  in if length parts == 1 then {
    object_id = elemAt parts 0;
  } else if length parts == 2 then {
    domain = elemAt parts 0;
    object_id = elemAt parts 1;
  } else throw "cannot parse hass reference: ${toString s}";

  bright = percent: 255 * percent / 100;
  h2s = hours: toString (hours * 60 * 60);
  m2s = minutes: toString (minutes * 60);
  time2s = { hours ? 0, minutes ? 0, seconds ? 0 }: (hours * 60 + minutes) * 60 + seconds;

  nameid = let
    stripSuffix = id: if hasSuffix "_" id then stripSuffix (substring 0 (stringLength id - 1) id) else id;
  in name: stripSuffix (toLower (replaceStrings
    [ " " "-" "." "!" "'" "Ü" "Ö" ]
    [ "_" "_" "_" "_" "_" "u" "o" ]
    name
  ));
  named = namedAs [ "object_id" ];
  namedAs = path: let
    apply = name: attrs: recursiveUpdate (setAttrByPath path name) attrs;
    applyFn = name: attrs: setFunctionArgs (args: apply name (attrs args)) (functionArgs attrs);
    #applyFn = name: attrs: setFunctionArgs ({ ... }: { imports = [ attrs { config = apply name { }; } ]; }) (functionArgs attrs);
  in mapAttrs' (name: attrs: let
    attrs' = if isFunction attrs
      then applyFn name attrs
      else apply name attrs;
  in nameValuePair (nameid name) attrs');

  timeNorm = { hours ? 0, minutes ? 0, seconds ? 0 }: let
    seconds' = mod seconds 60;
    minutes'' = minutes + seconds / 60;
    minutes' = mod minutes'' 60;
    hours' = hours + minutes'' / 60;
  in {
    hours = hours';
    minutes = minutes';
    seconds = seconds';
  };
  time = { hours ? 0, minutes ? 0, seconds ? 0 }: let
    time' = timeNorm { inherit hours minutes seconds; };
  in "${toString time'.hours}:${fixedWidthNumber 2 time'.minutes}:${fixedWidthNumber 2 time'.seconds}";

  inherit entityDomains;
  filterEntities = f: entities: filterAttrs (_: e: e != { }) (
    mapAttrs (domain: filterAttrs (_: f)) entities
  );
  mapEntitiesToList = f: entities: concatLists (mapAttrsToList (domain: entities: map f (attrValues entities)) entities);
  entitiesToList = mapEntitiesToList id;

  groupedEntities = entity:
    if isList entity then concatMap groupedEntities entity
    else if entity ? get then groupedEntities (entity.get { })
    else if entity ? create.entities then concatMap groupedEntities entity.create.entities
    else [ entity ];

  getSettings = { settings, ... }: settings;
  mapSettings = map getSettings;

  stateNot = state: {
    on = off;
    off = on;
  }.${state};
}
