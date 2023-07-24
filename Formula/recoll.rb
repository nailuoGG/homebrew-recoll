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
  url 'https://www.lesbonscomptes.com/recoll/recoll-1.35.0.tar.gz'
  sha256 "e66b0478709dae93d2d1530256885836595a14925d5d19fc95a63a04d06df941"
  option "build-from-source", "Build Recoll from source"

  def install
    ohai ARGV
    if ARGV.include? "--build-from-source"
      ohai "start install from source code"
        depends_on "xapian"
        depends_on "qt@5"
        depends_on "antiword"
        depends_on "poppler"
        depends_on "unrtf"
        depends_on "aspell"
        depends_on "exiftool"
      # Build from source
      # homebrew has webengine, not webkit and we're not ready for this yet
      system "./configure", "--disable-webkit",
                            "--disable-python-chm",
                            "QMAKE=qmake",
                            "--prefix=#{prefix}"
      system "make", "install"
    else
      ohai "start install from prebuild package "
      # Download and install the pre-built binary
      dmg_url = "https://www.lesbonscomptes.com/recoll/downloads/macos/recoll-1.33.4-20230107-097c8ea8.dmg"
      system "curl", "-L", "-o", "recoll.dmg", dmg_url
      system "hdiutil", "mount", "-nobrowse", "recoll.dmg"
      system "cp", "-R", "/Volumes/:Users:dockes:Recoll:recoll:src:build-recoll-win-Qt_6_2_4_for_macOS-Release:recoll/recoll.app", prefix
      system "hdiutil", "unmount", "/Volumes/:Users:dockes:Recoll:recoll:src:build-recoll-win-Qt_6_2_4_for_macOS-Release:recoll"
    end
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
