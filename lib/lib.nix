{ nixlib, self }: nixlib.extend (final: prev: let
  types = prev.types // {
    assertions = self.lib.modules.assertions;
  };
  checkAssertions = {
    config
  , assertions ? config.assertions
  , warnings ? config.warnings
  , output ? config
  }: let
    inherit (final.lists) filter;
    inherit (final.strings) concatStringsSep;
    inherit (final.trivial) showWarnings;
    failedAssertions = map (x: x.message) (filter (x: !x.assertion) assertions);

    assertWarn = value: if failedAssertions != []
      then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
      else showWarnings warnings value;
  in assertWarn output;
in self.lib.hass-lib // {
  inherit types checkAssertions;
})
