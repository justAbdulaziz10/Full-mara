{
  description = "Mara reproducible dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }:
  let pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [ pkgs.python310 pkgs.python310Packages.pip pkgs.k6 pkgs.git ];
      shellHook = ''
        echo "🐍 Python: $(python --version)"
        echo "k6 ready"
      '';
    };
  };
}
