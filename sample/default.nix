{ hass, config, lib, ... }: with hass; with lib; let
in {
  entities.input_boolean = {
    entry_overhead_override = {
      create = {
        platform = "input_boolean";
        name = "Entry Overhead Override";
      };
      customize.hidden = true;
    };
  };
  entities.sun.sun = { };
}
