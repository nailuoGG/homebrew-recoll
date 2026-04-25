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
  depends_on "python"
  depends_on "qt@6"
  depends_on "xapian"

  # Dynamically resolve Python version from the "python" formula dependency.
  # This follows Homebrew's latest Python (e.g. python@3.13 → python@3.14).
  def pyver
    @pyver ||= Formula["python"].version.to_s.split(".")[0..1].join(".")
  end

  def install
    # Upstream meson.build omits IOKit, needed by powerstatus.cpp on macOS
    iokit_dep = "    librecolldeps += dependency('IOKit', required: true)"
    inreplace "meson.build",
              "librecolldeps += core_services  # Add the CoreServices framework as a dependency",
              "librecolldeps += core_services  # Add the CoreServices framework as a dependency\n#{iokit_dep}"

    # Upstream rclgrep/meson.build misses iconv, CoreServices/IOKit, and
    # finderxattr.cpp (only added to librecoll, not rclgrep's source list)
    inreplace "rclgrep/meson.build" do |s|
      s.gsub! "rclgrep_deps = [libxml, libxslt, libz]",
              "rclgrep_deps = [libxml, libxslt, libz, dependency('iconv', method: 'auto')]"
      macos_patch = <<~MESON
        rclgrep_deps += libmagic
        if(apple_core_services_found)
            rclgrep_deps += core_services
            rclgrep_deps += dependency('IOKit', required: true)
        endif
      MESON
      s.gsub! "    rclgrep_deps += libmagic",
              macos_patch
      s.gsub! "    '../utils/zlibut.cpp',",
              "    '../utils/zlibut.cpp',\n    '../internfile/finderxattr.cpp',"
    end

    # Fix Meson installing Python modules to nested prefix/opt/homebrew/lib/...
    # by explicitly setting platlibdir/purelibdir to formula's lib directory
    python_site = lib/"python#{pyver}/site-packages"

    args = %W[
      -Dpython-module=true
      -Dpython.platlibdir=#{python_site}
      -Dpython.purelibdir=#{python_site}
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

    # Rewrite filter shebangs from #!/usr/bin/env python3 to the
    # versioned python (e.g. python3.14) matching the compiled extension
    # Not all .py files have a shebang (e.g. cmdtalk.py, conftree.py)
    python_bin = Formula["python"].opt_bin/"python#{pyver}"
    Dir[prefix/"share/recoll/filters/*.py"].each do |f|
      next unless File.read(f, 22).start_with?("#!/usr/bin/env python3")
      inreplace f, "#!/usr/bin/env python3", "#!#{python_bin}"
    end

    # Build .app bundle with macdeployqt (macOS only)
    build_app_bundle if OS.mac?
  end

  def build_app_bundle
    app = prefix/"Recoll.app"
    (app/"Contents/MacOS").mkpath
    (app/"Contents/Resources").mkpath

    # Copy GUI binary only (CLI tools stay in bin/)
    cp bin/"recoll", app/"Contents/MacOS/recoll"

    # Launcher script sets RECOLL_DATADIR, DYLD_LIBRARY_PATH, and PYTHONPATH
    # so .app finds share/recoll data, librecoll dylib, and Python modules
    python_site = lib/"python#{pyver}/site-packages"
    (app/"Contents/MacOS/recoll-launcher").write <<~SH
      #!/bin/sh
      export RECOLL_DATADIR="#{prefix}/share/recoll"
      export DYLD_LIBRARY_PATH="#{lib}:#{Formula["qt@6"].opt_lib}"
      export PYTHONPATH="#{python_site}:#{prefix}/share/recoll/filters"
      exec "#{app}/Contents/MacOS/recoll" "$@"
    SH
    chmod 0755, app/"Contents/MacOS/recoll-launcher"

    # Info.plist with unique bundle identifier
    (app/"Contents/Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleDisplayName</key>
        <string>Recoll (Homebrew)</string>
        <key>CFBundleExecutable</key>
        <string>recoll-launcher</string>
        <key>CFBundleIconFile</key>
        <string>recoll.icns</string>
        <key>CFBundleIdentifier</key>
        <string>org.recoll.Recoll.homebrew</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>Recoll</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>#{version}</string>
        <key>CFBundleVersion</key>
        <string>#{version}</string>
        <key>NSHighResolutionCapable</key>
        <true/>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
      </dict>
      </plist>
    XML

    # Copy icon from source tree
    icns = Dir[buildpath/"**/*.icns"].first
    cp icns, app/"Contents/Resources/recoll.icns" if icns

    # Inject Qt frameworks via macdeployqt
    system "#{Formula["qt@6"].opt_bin}/macdeployqt", app.to_s,
           "-always-overwrite",
           "-executable=#{app}/Contents/MacOS/recoll"
  end

  def caveats
    <<~EOS
      Recoll has been installed from source with Qt6 GUI support.

      To add Recoll.app to /Applications:
        ln -sf #{opt_prefix}/Recoll.app /Applications/Recoll-from-source.app

      CLI tools are in your PATH:
        recoll          # Start GUI
        recollindex     # Index files
        recollq         # Query index
        rclgrep         # Search without index

      IMPORTANT - Python filters:
        Some filters require additional Python packages. Install them with:
          pip#{pyver} install lxml mutagen

      IMPORTANT - Helper programs:
        Add the following to ~/.recoll/recoll.conf so Recoll can find
        external tools (aspell, antiword, etc.):
          recollhelperpath = #{HOMEBREW_PREFIX}/bin

      Configuration: ~/.recoll/
      Documentation: https://www.recoll.org/
    EOS
  end

  test do
    system bin/"recollindex", "-h"
    system Formula["python"].opt_bin/"python#{pyver}", "-c", "import recoll; print('recoll module OK')"
  end
end
