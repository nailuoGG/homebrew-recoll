cask 'recoll' do
  version 'recoll-1.43.5-20250830-c663a2a6'
  sha256 '880a3cd64b1d6f85c97b7542d0a35cd653f22ef61e46d081efd1ae93cdc13712'
  name 'Recoll'
  desc 'Full-text search for your desktop.'

  homepage 'https://www.recoll.org/'

  depends_on macos: '>= :big_sur'

  app 'Recoll.app'

  livecheck do
    url 'https://www.recoll.org/downloads/macos/'
    regex(/href="recoll[._-]([\d.-]+[a-f0-9]+)\.dmg"/i)
  end

  url "https://www.recoll.org/downloads/macos/recoll-#{version}.dmg"

  postflight do
    system_command 'xattr', args: ['-rd', 'com.apple.quarantine', "#{appdir}/Recoll.app"]
  end

  caveats do
    path_environment_variable "#{appdir}/Recoll.app/Contents/MacOS"
  end

  zap trash: [
    '~/.recoll',
    '~/.config/Recoll.org'
  ]
end
