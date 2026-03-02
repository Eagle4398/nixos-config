{ enableHWAcceleration ? false, pkgs }:
let
  nature-backgrounds = pkgs.stdenvNoCC.mkDerivation {
    name = "nature-images";
    src = pkgs.fetchurl {
      url =
        "https://www.dropbox.com/scl/fi/t6gnddx3lgrov56nj30de/nature-images.zip?rlkey=0t2jo103z63udj6emaiewgsth&st=y3poqskl&dl=1";
      sha256 = "sha256-XF3pPcVRE84wnesxO8aDFpsL81NK2YBWfnDr6ge2+SY=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    dontUnpack = true;
    buildPhase = ''
      unzip $src
    '';
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  litarvan-theme = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Eagle4398";
    repo = "sea-greeter-lightdm-webkit-theme-litarvan-nixpkg";
    rev = "6b4c0b0e96d39d02a689b35af986194933e4459d";
    sha256 = "sha256-y8PsEKDQeF+jAKFPZGdzrrzoUJXqonYQA7RV5CYKD8w=";
  } + /litarvan-theme.nix) { };
in {
  sea-greeter = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Eagle4398";
    repo = "sea-greeter-lightdm-webkit-theme-litarvan-nixpkg";
    rev = "682328e5298eba76dbe4518019ac53b5acee2541";
    sha256 = "sha256-6ec2EnN2Kn+m5JqCevy/fNx/+TkKzsvhMvoNPTf0qIU=";
  } + /sea-greeter.nix) {
    theme = litarvan-theme;
    backgrounds = nature-backgrounds;
    enableHWAcceleration = enableHWAcceleration;
  };
}
