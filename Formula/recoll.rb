require 'formula'

# Notes:
# - This formula is missing python-libxml2 and python-libxslt deps
#   which recoll needs for indexing many formats (e.g. libreoffice,
#   openxml). Homebrew does not include these packages.
#   So the user needs to install them with pip because I don't understand how
#   the "Resource" homebrew thing works.
# Still a bit of work then, but I did not investigate, because the macports
# version was an easier target.

class Recoll < Formula
  desc "Desktop search tool"
  homepage 'http://www.recoll.org'
  url 'https://www.lesbonscomptes.com/recoll/recoll-1.27.3.tar.gz'
  sha256 "3f62b792f57895a20dd334eb841d6fbe851e687dab43ea89cb3fbc0ccebcddac"

  depends_on "xapian"
  depends_on "qt"
  depends_on "antiword"
  depends_on "poppler"
  depends_on "unrtf"
  depends_on "aspell"

  def install
    # homebrew has webengine, not webkit and we're not ready for this yet
    system "./configure", "--disable-python-module",
                          "--disable-webkit",
                          "--disable-python-chm",
                          "QMAKE=/usr/local/opt/qt/bin/qmake",
                          "--prefix=#{prefix}"
    system "make", "install"
    bin.install "#{buildpath}/qtgui/recoll.app/Contents/MacOS/recoll"
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
