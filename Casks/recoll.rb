cask "recoll" do
  version "1.43.6-20251014-af2d6350"
  sha256 "92c00c2049808a6fa0447eb033f03885826d4b19411d13f02b6e0233939b91bd"

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
