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
  depends_on "antiword"  # For MS Word documents
  depends_on "unrtf"     # For RTF documents
  depends_on "perl"      # For ExifTool installation
  depends_on "python@3.13"

  def install
    system "meson", "setup", "build",
           "-Dx11mon=false",
           "-Dwebengine=true",
           "-Dsystemd=false",
           "-Dprefix=#{prefix}"
    system "ninja", "-C", "build"
    system "ninja", "-C", "build", "install"
    
    # Link the .app bundle to Applications
    prefix.install "build/qtgui/recoll.app"
    Applications.install_symlink prefix/"recoll.app"

    # Fix Python extensions location (meson bug workaround)
    if Dir.exist?("#{prefix}/usr/local/lib/python3.13/site-packages")
      system "mv", "#{prefix}/usr/local/lib/python3.13/site-packages/*", "#{prefix}/lib/python3.13/site-packages/"
      system "rm", "-rf", "#{prefix}/usr/local"
    end
  end

  def caveats
    <<~EOS
      To enable image tags indexing, install ExifTool:
        cpan Image::ExifTool

      For full functionality, install these Python modules:
        pip3 install --user --break-system-packages lxml mutagen py7zr pyyaml

      Note: Python modules will be installed in ~/Library/Python/3.13/lib/python/site-packages
    EOS
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
