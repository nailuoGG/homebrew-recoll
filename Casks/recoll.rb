cask 'recoll' do
  version 'recoll-1.43.4-20250808-51dfd558.dmg'
  sha256 'bef4f70d5a7f90cfee4e9bd0781d4193bd1853bdb741e93f1e36dda9ebf9bd04'
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
