let
  hassRefModule = { domain, meta, hass, config, types, lib, ... }: with lib; let
    domainInfo = meta.domain.${config.domain};
  in {
    options = with types; {
      object_id = mkOption {
        type = stringlike;
        apply = toString;
      };
      domain = mkOption {
        type = str;
      };
      reference = mkOption {
        type = str;
        default = let
          ref = if domainInfo.implicitDomain then config.object_id else "${config.domain}.${config.object_id}";
        in if config.domain == domain || domain == null
          then ref
          else throw "Expected reference to ${domain}, got ${config.domain}.${config.object_id}";
        readOnly = true;
      };
      get = mkOption {
        type = functionTo unspecified;
        default = _: domainInfo.get config.object_id;
      };
      __toString = mkOption {
        type = functionTo str;
        default = self: self.reference;
      };
    };
    config = {
      domain = mkIf (domain != null) (mkOptionDefault domain);
    };
  };
  objectIdModule = { config, types, lib, ... }: with lib; {
    options = with types; {
      object_id = mkOption {
        type = str;
        default = nameid config.name;
      };
      name = mkOption {
        type = stringlike;
        apply = toString;
      };
      __toString = mkOption {
        type = functionTo str;
        default = self: self.object_id;
      };
    };
  };
in { config, types, lib, ... }: with lib; {
  config.lib.types = with types; {
    hassRefOf = domain: submoduleWith {
      modules = [ hassRefModule ];
      specialArgs = config.lib.specialArgs // {
        inherit domain;
      };
    };
    hassRef = let
      convertObj = reference: {
        inherit (reference) object_id;
        ${if reference ? domain then "domain" else null} = reference.domain;
      };
    in domain: coercedTo (either stringlike hassObject) (ref:
      if ref ? object_id then convertObj ref else parseRef ref
    ) (hassRefOf domain);
    hassRefEntity = hassRef null;
    objectId' = submoduleWith {
      modules = [ objectIdModule ];
      specialArgs = config.lib.specialArgs;
    };
    objectId = coercedTo (either attrs str) (ref:
      if ref ? name then { inherit (ref) name; } else if isString ref then { name = ref; } else { name = ref.object_id; }
    ) objectId';
  };
}
