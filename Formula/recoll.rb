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
  homepage 'http://www.recoll.org'
  url 'https://www.lesbonscomptes.com/recoll/recoll-1.32.1.tar.gz'
  sha256 "d4bceab56d9a1a38a7e8cd34bf3d9d4f76fbd446388eb7081a46ab362d7f4cc0"

  depends_on "xapian"
  depends_on "qt@5"
  depends_on "antiword"
  depends_on "poppler"
  depends_on "unrtf"
  depends_on "aspell"
  depends_on "exiftool"

  def install
    # homebrew has webengine, not webkit and we're not ready for this yet
    system "./configure", "--disable-webkit",
                          "--disable-python-chm",
                          "--disable-qtgui",
                          "--prefix=#{prefix}"
    system "make", "install"
#    bin.install "#{buildpath}/qtgui/recoll.app/Contents/MacOS/recoll"
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
