cask "recoll" do
  version "1.45.0-20261027-c2978c94"
  sha256 "9f77b6231686cffab651739538e2364a37a4df6649b26eaef230d8a5816c3ccb"
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
