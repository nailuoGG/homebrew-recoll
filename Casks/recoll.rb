cask 'recoll' do
  version '1.38.1-20240516-375bcbc0'
  sha256 '5c15e9000666c7019d641e62e9a3f751c35f44cd0009da76cdf0e31eceb9353f'
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

    ruby do
      dir = '~/.recoll'
      Dir.mkdir(dir) unless Dir.exist?(dir)
      file_path = "#{dir}/recoll.conf"

      File.open(file_path, 'w') do |f|
        f.puts("recollhelperpath=#{ENV['PATH'].split(':').sort.join(':')}")
      end
    end
  end

  caveats do
    path_environment_variable "#{appdir}/Recoll.app/Contents/MacOS"
  end

  zap trash: [
    '~/.recoll',
    '~/.config/Recoll.org'
  ]
end
