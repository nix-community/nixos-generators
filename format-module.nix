{ lib, ... }: {
  options = {
    filename = lib.mkOption {
      type = lib.types.str;
      description = "Declare the path of the wanted file in the output directory";
      default = "*";
    };
    formatAttr = lib.mkOption {
      type = lib.types.str;
      description = "Declare the default attribute to build";
    };
  };
}

