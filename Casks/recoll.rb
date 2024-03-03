cask "recoll" do
  version "1.37.4-20240208-89366c8a"
  sha256 "2c93ce3fd54842b3d6ebcbe71b182447bb80e8e50fe316916558166a9310485c"

  url "https://www.lesbonscomptes.com/recoll/downloads/macos/recoll-#{version}.dmg"
  name "Recoll"
  desc "Full-text search tool"
  homepage "https://www.lesbonscomptes.com/recoll/"

  app "Recoll.app"

  postflight do
    system_command "xattr", args: ["-rd", "com.apple.quarantine", "#{appdir}/Recoll.app"]
  end

  caveats <<~EOS
    For Recoll to find commands, set recollhelperpath in ~/.recoll/recoll.conf:

    Intel Mac:
    echo "recollhelperpath = /usr/local/bin" >> ~/.recoll/recoll.conf

    Apple Silicon Mac:
    echo "recollhelperpath = /opt/homebrew/bin" >> ~/.recoll/recoll.conf

    To use recoll and recollindex from the terminal, add Recoll.app to your PATH:
    echo 'export PATH=/Applications/Recoll.app/Contents/MacOS:$PATH' >> ~/.zshrc

    Adjust ~/.zshrc to your shell's config file if you use a different shell.
  EOS

  zap trash: []
end
