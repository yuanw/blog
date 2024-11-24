{
  perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
    checks = config.packages;

    packages.blog = pkgs.buildNpmPackage {
      pname = "blog";
      version = "0.2.0";

      inherit (config.packages) nodejs;

      src = ./.;

      buildInputs = [
        pkgs.vips
      ];

      nativeBuildInputs = [
        pkgs.pkg-config
      ];

      installPhase = ''
        runHook preInstall
        cp -pr --reflink=auto dist $out/
        runHook postInstall
      '';
      #npmDepsHash = "sha256-xvDnu81wK10uGVA9VI98WaKAQ8o9ou+FVBJo5r5bClE=";
       npmDepsHash = lib.fakeHash; 

    };
  };
}
