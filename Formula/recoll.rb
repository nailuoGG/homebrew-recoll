require 'formula'
# Notes:
# - This formula is missing python-libxml2 and python-libxslt deps
#   which recoll needs for indexing many formats (e.g. libreoffice,
#   openxml). Homebrew does not include these packages.
#   So the user needs to install them with pip because I don't understand how
#   the "Resource" homebrew thing works.
# Still a bit of work then, but I did not investigate, because the macports
# version was an easier target.

#  copy from https://framagit.org/medoc92/recoll/-/blob/master/packaging/homebrew/recoll.rb
class Recoll < Formula
  desc "Desktop search tool"
  homepage "http://www.recoll.org"
  url "https://www.lesbonscomptes.com/recoll/recoll-1.35.0.tar.gz"
  sha256 "e66b0478709dae93d2d1530256885836595a14925d5d19fc95a63a04d06df941"

  option "build-from-source", "Build from source instead of using precompiled binary"

  depends_on "xapian"
  depends_on "qt@5"
  depends_on "antiword"
  depends_on "poppler"
  depends_on "unrtf"
  depends_on "aspell"
  depends_on "exiftool"

  def install
    if build.with? "build-from-source"
      # homebrew has webengine, not webkit and we're not ready for this yet
      system "./configure", "--disable-webkit",
                            "--disable-python-chm",
                            "QMAKE=qmake",
                            "--prefix=#{prefix}"
      system "make", "install"
      bin.install "#{buildpath}/qtgui/recoll.app/Contents/MacOS/recoll"
    else
      # Install precompiled binary
      prefix.install Dir["*"]
    end
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
