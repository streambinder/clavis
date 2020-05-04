{ pkgs, stdenv, fetchFromGitHub, gcc-unwrapped, pkgconfig, gtk2, curl, libyaml
, ... }:

stdenv.mkDerivation rec {

  pname = "paperboy";
  version = "v3";

  src = fetchFromGitHub {
    owner = "streambinder";
    repo = "paperboy";
    rev = "${version}";
    sha256 = "1hkn4pdbj2hbzhrn13dz2vq5mglnfk74wqrb0g98y31p2grmdqqh";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ curl gtk2 libyaml ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./paperboy $out/bin/paperboy
  '';

  meta = with stdenv.lib; {
    description = ''
      IMAP email checker and GTK notifier.
    '';
    homepage = "https://davidepucci.it/doc/paperboy";
    maintainers = with maintainers; [ streambinder ];
    license = licenses.gpl3;
  };
}
