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
    
    # Install the .app bundle
    prefix.install "build/qtgui/recoll.app"
  end

  def caveats
    python_fix_msg = if Dir.exist?("#{prefix}/usr/local/lib/python3.13/site-packages")
      <<~EOS
        Some Python extensions are in the wrong location. To fix this, run:
          sudo mv #{prefix}/usr/local/lib/python3.13/site-packages/* #{prefix}/lib/python3.13/site-packages/
          sudo rm -rf #{prefix}/usr/local
      EOS
    end

    <<~EOS
      Recoll.app was installed to:
        #{prefix}

      To link the application to default Homebrew App location:
        osascript -e 'tell application "Finder" to make alias file to posix file "#{prefix}/recoll.app" at posix file "/Applications" with properties {name:"Recoll.app"}'

      To enable image tags indexing, install ExifTool:
        cpan Image::ExifTool

      For full functionality, install these Python modules:
        pip3 install --user --break-system-packages lxml mutagen py7zr pyyaml

      Note: Python modules will be installed in ~/Library/Python/3.13/lib/python/site-packages

      #{python_fix_msg}
    EOS
  end

  test do
    system "#{bin}/recollindex", "-h"
  end
end
