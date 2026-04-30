{
  description = "Generate the MuseScore handbook PDF in Australian English";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          fontsConf = pkgs.makeFontsConf {
            fontDirectories = [
              pkgs.dejavu_fonts
              pkgs.noto-fonts
              pkgs.noto-fonts-cjk-sans
              pkgs.noto-fonts-color-emoji
            ];
          };
        in
        {
          default = pkgs.writeShellApplication {
            name = "mscore-handbook2pdf";
            runtimeInputs = [
              pkgs.bash
              pkgs.cacert
              pkgs.coreutils
              pkgs.wkhtmltopdf
            ];
            text = ''
              export FONTCONFIG_FILE="${fontsConf}"
              export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              export HANDBOOK_XSL="${./custom.xslt}"
              exec bash "${./run.sh}" "$@"
            '';
          };
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/mscore-handbook2pdf";
        };
      });
    };
}
