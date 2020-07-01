{ stdenv
, buildPythonPackage
, isPyPy
, python
, pkgs
, pillow
, pycairo
, pyproj
, pytestCheckHook
, nose
}:

let
  boost = pkgs.boost.override {
    enablePython = true;
    inherit python;
  };
  mapnik = pkgs.mapnik.override {
    inherit python boost;
  };

in buildPythonPackage rec {
  pname = "python-mapnik";
  version = "unstable-2020-02-24";

  src = pkgs.fetchFromGitHub {
    owner = "mapnik";
    repo = "python-mapnik";
    rev = "7da019cf9eb12af8f8aa88b7d75789dfcd1e901b";
    sha256 = "0snn7q7w1ab90311q8wgd1z64kw1svm5w831q0xd6glqhah86qc8";
  };

  disabled = isPyPy;
  doCheck = true;
  preBuild = let
    pythonVersion = with stdenv.lib.versions; "${major python.version}${minor python.version}";
    test-data = pkgs.fetchFromGitHub {
      owner = "mapnik";
      repo = "test-data";
      rev = "99da07d5e76ccf5978ef0a380bf5f631f9088584";
      sha256 = "0y0ifjw848ylfbi84yxkgxqlz0vbarggphvkz24adzzsfgxpcd58";
    };
  in ''
    export BOOST_PYTHON_LIB="boost_python${pythonVersion}"
    export BOOST_THREAD_LIB="boost_thread"
    export BOOST_SYSTEM_LIB="boost_system"
    rmdir test/data*
    ln -sf ${test-data} test/data
    ${python.interpreter} ./setup.py build_ext --inplace
  '';

  nativeBuildInputs = [
    mapnik # for mapnik_config
  ];
  postInstall = ''
    echo "env = {'ICU_DATA': '${pkgs.icu}','GDAL_DATA': '${pkgs.gdal}','PROJ_LIB': '${pkgs.proj}'}" > $out/lib/python3.8/site-packages/mapnik/mapnik_settings.py
    echo "SEMPF1"
    find .
    echo "SEMPF2"
    find $out

  '';

  buildInputs = [
    mapnik
    boost
  ] ++ (with pkgs; [
    cairo
    harfbuzz
    icu
    libjpeg
    libpng
    libtiff
    libwebp
    proj
    zlib
  ]);
  checkInputs = [
    pytestCheckHook
    nose
  ];
  propagatedBuildInputs = [ pillow pycairo pyproj ];

  meta = with stdenv.lib; {
    description = "Python bindings for Mapnik";
    homepage = "https://mapnik.org";
    license  = licenses.lgpl21;
  };

}
