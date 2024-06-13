cask "recoll" do
  version "1.38.1-20240516-375bcbc0"
  sha256 "5c15e9000666c7019d641e62e9a3f751c35f44cd0009da76cdf0e31eceb9353f"

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
