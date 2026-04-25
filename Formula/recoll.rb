class Recoll < Formula
  desc "Full-text search for your desktop"
  homepage "https://www.recoll.org/"
  url "https://www.recoll.org/recoll-1.43.14.tar.gz"
  sha256 "391e5c6edb78c6cd487d94c5abe44fe0c64f99f0acdab287d5821fd4e806f89b"
  license "GPL-2.0-or-later"
  head "https://framagit.org/medoc92/recoll.git", branch: "master"

  livecheck do
    url "https://www.recoll.org/pages/download.html"
    regex(/href=.*?recoll[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "aspell"
  depends_on "jsoncpp"
  depends_on "libmagic"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "python@3.13"
  depends_on "qt@6"
  depends_on "xapian"

  def install
    # Fix missing IOKit framework for power status on macOS
    iokit_line = "    librecolldeps += dependency('IOKit', required: true)"
    inreplace "meson.build",
              "librecolldeps += core_services  # Add the CoreServices framework as a dependency",
              "librecolldeps += core_services  # Add the CoreServices framework as a dependency\n#{iokit_line}"

    # Fix rclgrep missing iconv and macOS framework deps
    iconv_dep = "dependency('iconv', method: 'auto')"
    inreplace "rclgrep/meson.build",
              "rclgrep_deps = [libxml, libxslt, libz]",
              "rclgrep_deps = [libxml, libxslt, libz, #{iconv_dep}]"
    rclgrep_macos = [
      "    rclgrep_deps += libmagic",
      "    if(apple_core_services_found)",
      "        rclgrep_deps += core_services",
      "        rclgrep_deps += dependency('IOKit', required: true)",
      "    endif",
    ].join("\n")
    inreplace "rclgrep/meson.build",
              "    rclgrep_deps += libmagic",
              rclgrep_macos
    inreplace "rclgrep/meson.build",
              "    '../utils/zlibut.cpp',",
              "    '../utils/zlibut.cpp',\n    '../internfile/finderxattr.cpp',"

    args = %w[
      -Dpython-module=true
      -Dqtgui=true
      -Dfsevents=true
      -Daspell=true
      -Drecollq=true
      -Drclgrep=true
      -Dwebkit=false
      -Dwebengine=true
      -Dwebpreview=true
      -Didxthreads=false
      -Dx11mon=false
      -Dinotify=false
      -Dsystemd=false
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  def caveats
    <<~EOS
      Recoll has been installed from source with Qt6 GUI support.

      To start the GUI:
        recoll

      To index your home directory:
        recollindex

      Configuration files are stored in ~/.recoll/

      For more information:
        https://www.recoll.org/
    EOS
  end

  test do
    system bin/"recollindex", "-h"
  end
end
