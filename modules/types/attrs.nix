{ config, types, lib, ... }: with lib; let
  hassAttrs = { domain ? null, modules ? [ ], topModules ? [ ], specialArgs ? { }, attrsOf ? types.attrsOf, freeform ? true }@args: let
    specialArgs = args.specialArgs or { } // config.lib.specialArgs // {
      ${mapNullable (_: "domain") domain} = domain;
    };
    modules' = if isFunction modules then modules else _: modules;
    attrType = args: attrsOf (hassAttrs' {
      inherit specialArgs freeform;
      modules = modules' args;
    });
    nested = types.submoduleWith {
      modules = topModules ++ [
        (setFunctionArgs ({ ... }@args: {
          config._module.freeformType = attrType args;
        }) (functionArgs modules'))
      ];
      inherit specialArgs;
    };
    plain = attrType specialArgs;
  in if topModules != [ ] then nested else plain;
  hassAttrs' = {
    modules
  , specialArgs
  , freeform
  }: with types; submoduleWith {
    modules = modules ++ optional freeform ({ ... }: {
      config._module.freeformType = json.attrs;
    });
    inherit specialArgs;
  };
in {
  config.lib.types = {
    inherit hassAttrs;
    domainAttrsOf = todo types.attrsOf;
    domainAttrs = { ... }@args: types.domainAttrsOf (types.hassAttrs (args // {
      modules = { domain, ... }: args.modules or [ ] ++ [
        ({ ... }: {
          config._module.args = {
            inherit domain;
          };
        })
      ];
      topModules = args.topModules or [ ] ++ [
        ({ name, ... }: {
          config._module.args.domain = name;
        })
      ];
    }));
    hassAttrsModule = { nested ? false, modules, ... }@args: with types; let
      attrsType = attrsOf (submoduleWith {
        inherit modules;
      });
      nested' = submoduleWith {
        modules = singleton ({ ... }: {
          freeformType = attrsType;
        });
      };
      plain = attrsType;
      args' = removeAttrs args [ "nested" "modules" ];
    in mkOption ({
      type = if nested then nested' else plain;
    } // args');
  };
}
