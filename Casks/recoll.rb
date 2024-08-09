cask 'recoll' do
  version '1.38.1-20240516-375bcbc0'
  sha256 '5c15e9000666c7019d641e62e9a3f751c35f44cd0009da76cdf0e31eceb9353f'

  url "https://www.recoll.org/downloads/macos/recoll-#{version}.dmg"
  name 'Recoll'
  desc 'Recoll finds documents based on their contents as well as their file names.'

  homepage 'https://www.recoll.org/'

  app 'Recoll.app'

  livecheck do
    url 'https://www.recoll.org/downloads/macos/'
    regex(/href="recoll[._-]([\d.-]+[a-f0-9]+)\.dmg"/i)
  end

  postflight do
    system_command 'xattr', args: ['-rd', 'com.apple.quarantine', "#{appdir}/Recoll.app"]
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
