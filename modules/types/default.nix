{ config, lib, ... }: {
  imports = [
    ./json.nix
    ./unmerged.nix
    ./settings.nix
    ./attrs.nix
    ./object.nix
    ./ref.nix
    ./condition.nix
    ./action.nix
    ./trigger.nix
  ];
  config = {
    lib.specialArgs = {
      inherit (config.lib) types;
    };
    lib.types = with lib; with types; lib.types // {
      submoduleWith = args: lib.types.submoduleWith ({
        shorthandOnlyDefinesConfig = true;
      } // args);
      toListOf = elemType: types.coercedTo types.attrs singleton (types.listOf elemType);
      stringlike = mkOptionType {
        name = "stringlike";
        description = "stringlike";
        descriptionClass = "noun";
        check = isStringLike;
        merge = options.mergeEqualOption;
      };
    };
  };
}
