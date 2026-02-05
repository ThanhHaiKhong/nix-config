{ lib
, stdenv
, fetchFromGitHub
, go
}:

stdenv.mkDerivation rec {
  pname = "cliproxyapi";
  version = "unstable-2026-02-05";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "4874253d1e82d08c613d8ce343532415d2065caf";
    sha256 = "sha256-mD0ZckACFF71m24sX5kRxXrfnH61Jo/7Tjai8/kc42Y=";
  };

  nativeBuildInputs = [ go ];

  # Remove the vendor directory to avoid issues
  postUnpack = ''
    echo "Removing vendor directory to avoid issues"
    rm -rf "$sourceRoot/vendor"
  '';

  buildPhase = ''
    runHook preBuild
    export GOPATH="$PWD/go"
    export GOCACHE="$TMPDIR/go-cache"
    export CGO_ENABLED=0

    # Create a temporary GOPATH directory
    mkdir -p "$GOPATH"

    # Build the application
    mkdir -p $out/bin
    go build -mod=readonly -ldflags="-s -w -X main.Version=${version}" -o $out/bin/cliproxyapi ./cmd/server
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "A proxy API service for various AI services (OpenAI, Claude, Qwen, etc.)";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    maintainers = with maintainers; [ thanhhaikhong ];
    platforms = platforms.unix ++ platforms.darwin;
  };
}