{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.flake-utils.url = github:poscat0x04/flake-utils;

  outputs = { self, nixpkgs, flake-utils, ... }: with flake-utils;
    eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
        in
          with pkgs;
          {
            devShell = ghc-with-hoogle-demo-dev.envFunc { withHoogle = true; };
            defaultPackage = ghc-with-hoogle-demo;
          }
    ) // {
      overlay = self: super:
        let
          hpkgs = super.haskellPackages;
          ghc-with-hoogle-demo = hpkgs.callCabal2nix "ghc-with-hoogle-demo" ./. {};
        in
          with super; with haskell.lib;
          {
            inherit ghc-with-hoogle-demo;
            ghc-with-hoogle-demo-dev = addBuildTools ghc-with-hoogle-demo [
              haskell-language-server
              cabal-install
            ];
          };
    };
}
