class Recoll < Formula
  desc "Desktop full-text search tool"
  homepage "https://www.lesbonscomptes.com/recoll/"
  url "https://www.lesbonscomptes.com/recoll/recoll-1.41.0.tar.gz"
  sha256 "c219d62f0bb4fb2bd5d847e4e8097d76f27d0c4684259f0e7a3229768dcaf4b2"
  license "GPL-2.0-or-later"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "aspell"
  depends_on "chmlib"
  depends_on "libmagic"
  depends_on "libxml2"
  depends_on "xapian"
  depends_on "qt@5"

  def install
    system "meson", "setup", "build",
           "-Dx11mon=false",
           "-Dwebengine=true",
           "-Dsystemd=false",
           "-Dprefix=#{prefix}"
    system "ninja", "-C", "build"
    system "ninja", "-C", "build", "install"
    
    # Copy the .app bundle to /Applications
    prefix.install "build/qtgui/recoll.app"
    (prefix/"recoll.app").cp_r "/Applications/"
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
