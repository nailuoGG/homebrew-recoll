cask "recoll" do
  version "1.44.2-20260930-6be10191"
  sha256 "b5f09df0dca19fccbe2ca4cbbb99e202530533ccb9abcb1a5e5cc374ea37b863"

  url "https://www.recoll.org/downloads/macos/recoll-#{version}.dmg"
  name "Recoll"
  desc "Full-text search for your desktop"
  homepage "https://www.recoll.org/"

  livecheck do
    url "https://www.recoll.org/downloads/macos/"
    regex(/href="recoll[._-]([\d.-]+[a-f0-9]+)\.dmg"/i)
  end

  depends_on macos: :big_sur

  app "Recoll.app"

  postflight do
    system_command "xattr", args: ["-rd", "com.apple.quarantine", "#{appdir}/Recoll.app"]
  end

  zap trash: [
    "~/.config/Recoll.org",
    "~/.recoll",
  ]
end
