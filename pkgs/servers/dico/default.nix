{ fetchurl, stdenv, libtool, gettext, zlib, readline, gsasl
, guile, python, pcre, libffi, groff, libiconv }:

stdenv.mkDerivation rec {
  name = "dico-2.5";

  src = fetchurl {
    url = "mirror://gnu/dico/${name}.tar.xz";
    sha256 = "0szm3z4xvq0pjj8kxl4paq63byamf281kzn1la0cdm5ngavypxxq";
  };

  hardeningDisable = [ "format" ];

  # XXX: Add support for GNU SASL.
  buildInputs =
    [ libtool gettext zlib readline gsasl guile python pcre libffi groff libiconv ];
  configureFlags = [
    "--with-libiconv-prefix=${libiconv}"
  ];
  # dicod fails to load modules, so the tests fail
  doCheck = false;

  preBuild = ''
    sed -i -e '/gets is a security/d' gnu/stdio.in.h
  '';

  meta = with stdenv.lib; {
    description = "Flexible dictionary server and client implementing RFC 2229";
    homepage    = http://www.gnu.org/software/dico/;
    license     = licenses.gpl3Plus;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.unix;

    longDescription = ''
      GNU Dico is a flexible modular implementation of DICT server
      (RFC 2229).  In contrast to another existing servers, it does
      not depend on particular database format, instead it handles
      database accesses using loadable modules.

      The package includes several loadable modules for interfacing
      with various database formats, among them a module for dict.org
      databases and a module for transparently accessing Wikipedia or
      Wiktionary sites as a dictionary database.

      New modules can easily be written in C, Guile or Python.  The
      module API is mature and well documented.

      A web interface serving several databases is available.

      The package also includes a console client program for querying
      remote dictionary servers.
    '';
  };
}
