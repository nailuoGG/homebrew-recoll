cask "recoll" do
  version "1.45.0-20261103-c2978c94"
  sha256 "e9078ef8b9c15ee7e14c405c056e86f091a75c84d37749ee07911ae8ebb3d9e7"
  url "https://www.recoll.org/downloads/macos/recoll-#{version}.dmg"
  name "Recoll"
  desc "Full-text search for your desktop"
  homepage "https://www.recoll.org/"

  livecheck do
    url "https://www.recoll.org/downloads/macos/"
    regex(/href="recoll[._-]([\d.-]+[a-f0-9]+)\.dmg"/i)
  end

  depends_on macos: :monterey

  app "recoll.app", target: "Recoll.app"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{appdir}}/Recoll.app"]
  end

  zap trash: [
    "~/.config/Recoll.org",
    "~/.recoll",
  ]
end
