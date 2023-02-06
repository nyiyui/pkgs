let
  rev = "cc6ea766c495cf4c69d1c7485728ba022b0f19de";
  sha256 = "1pq6k5dwlv85g3fwizsq45fkgs8mg1ix4andnxrp4z2ibmycwi2f";
in {
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in rec {
    packages.udp2raw = pkgs.stdenv.mkDerivation {
      name = "udp2raw";
      src = pkgs.fetchFromGitHub {
        owner = "wangyu-";
        repo = "udp2raw";
        inherit rev;
        inherit sha256;
      };
      buildPhase = ''
        make dynamic
      '';
      postFixup = ''
        wrapProgram $out/bin/udp2raw \
          --set PATH ${pkgs.lib.makeBinPath [ pkgs.iptables ]}
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp udp2raw_dynamic $out/bin/udp2raw
      '';
      nativeBuildInputs = with pkgs; [
        pkg-config
        pkgs.makeWrapper
      ];
    };
  });
}
