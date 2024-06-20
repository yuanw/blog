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
      # npmDepsHash = lib.fakeHash;
      npmDepsHash = "sha256-Iovqpxpv88zCrgMXfsOA7SPUg3gBh/1kq3WQjidXxTs=";
    };
  };
}
