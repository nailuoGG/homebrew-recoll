cask 'recoll' do
  version '1.43.6-20251014-af2d6350'
  sha256 '92c00c2049808a6fa0447eb033f03885826d4b19411d13f02b6e0233939b91bd'
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
