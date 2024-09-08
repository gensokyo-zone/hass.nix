{ types, lib, ... }: with lib; with types; {
  config.lib.types = {
    json = {
      data = oneOf [ json.primitive json.attrs json.list ] // {
        description = "json data";
      };
      primitives = [ bool int float stringlike ];
      primitive = nullOr (oneOf json.primitives);
      attrs = attrsOf json.data;
      lazyAttrs = lazyAttrsOf json.data;
      list = listOf json.data;
    };
  };
}
