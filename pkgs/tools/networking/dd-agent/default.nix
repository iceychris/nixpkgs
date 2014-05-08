{ stdenv, fetchGitHub, python, pythonPackages, sysstat, unzip, tornado
, makeWrapper }:

stdenv.mkDerivation rec {
  version = "4.2.1";
  name = "dd-agent-${version}";

  src = fetchGitHub {
    owner = "DataDog";
    repo = "dd-agent";
    rev = version;
    sha256 = "06f9nkvnpfzs2nw75cac2y9wnp2bay4sg94zz0wjm8886rigjjjm";
  };

  buildInputs = [ python unzip makeWrapper pythonPackages.psycopg2 ];
  propagatedBuildInputs = [ python tornado ];

  postUnpack = "export sourceRoot=$sourceRoot/packaging";

  makeFlags = [ "BUILD=$(out)" ];

  installTargets = [ "install_base" "install_full" ];

  postInstall = ''
    mv $out/usr/* $out
    rmdir $out/usr
    wrapProgram $out/bin/dd-forwarder \
      --prefix PYTHONPATH : $PYTHONPATH
    wrapProgram $out/bin/dd-agent \
      --prefix PYTHONPATH : $PYTHONPATH
    wrapProgram $out/bin/dogstatsd \
      --prefix PYTHONPATH : $PYTHONPATH
  '';

  meta = {
    description = "Event collector for the DataDog analysis service";
    homepage    = http://www.datadoghq.com;
    license     = stdenv.lib.licenses.bsd3;
    platforms   = stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ thoughtpolice iElectric ];
  };
}
