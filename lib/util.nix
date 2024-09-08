{ lib, hass-lib }: let
  inherit (lib)
    isString optionalString replaceStrings toLower toUpper stringToCharacters
    filterAttrs genAttrs nameValuePair listToAttrs optionalAttrs attrNames recursiveUpdate
    isList singleton elemAt foldl optionals imap0
    mod flip id;
  inherit (hass-lib)
    update
    hexCharToInt hexChars toHexLower
    unlessNull todo;
in {
  a = singleton;
  update = a: b: a // b;
  foldAttrList = foldl update {};
  foldAttrListRecursive = foldl recursiveUpdate {};
  mapListToAttrs = f: l: listToAttrs (map f l);
  unlessNull = item: alt: if item == null then alt else item;
  coalesce = foldl unlessNull null;
  cleanAttrs = filterAttrs (_: a: a != { } && a != [ ]);
  retainAttrs = attrs: whitelist: let
    attrlist = genAttrs whitelist (_: null);
  in filterAttrs (k: _: attrlist ? ${k}) attrs;

  hexChars = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" ];
  hexCharToInt = char: let
    pairs = imap0 (flip nameValuePair) hexChars;
    idx = listToAttrs pairs;
  in idx.${toLower char};
  hexToInt = str:
    foldl (value: chr: value * 16 + hexCharToInt chr) 0 (stringToCharacters str);
  toHex = toHexLower;
  toHexLower = int: let
    rest = int / 16;
  in optionalString (int >= 16) (toHexLower rest) + elemAt hexChars (mod int 16);
  toHexUpper = int: toUpper (toHexLower int);

  escapeRegex = let
    escapeChars = [ ''\'' "." "^" "$" "|" "?" "*" "+" "(" ")" "[" "]" "{" "}" ];
    escaped = map (c: ''\${c}'') escapeChars;
  in replaceStrings escapeChars escaped;

  todo = lib.warn "TODO";
  unimplemented = throw "UNIMPL";
  later = v: let
    op = if isList v then optionals
    else if isString v then optionalString
    else optionalAttrs;
  in todo (op false v);

  uniqueStrings = ls: attrNames (genAttrs ls id);
}
