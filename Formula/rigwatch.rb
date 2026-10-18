class Rigwatch < Formula
  desc "Mission control for a developer's Mac: agents, emulators, builds and caches"
  homepage "https://github.com/bravoshubham/rigwatch"
  url "https://github.com/bravoshubham/rigwatch/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "3e2d518d44acd28ce98d4dd516700e3a3d1840f50a1179e456686880ab386aa2"
  license "MIT"
  head "https://github.com/bravoshubham/rigwatch.git", branch: "main"

  depends_on macos: :sonoma

  def install
    # Built here from source, so the app carries no quarantine flag and Gatekeeper does not block it.
    ENV["RIGWATCH_APP"] = (prefix/"RigWatch.app").to_s
    ENV["RIGWATCH_SWIFT_FLAGS"] = "--disable-sandbox"
    system "./bundle.sh"

    (bin/"rigwatch").write <<~SH
      #!/bin/bash
      exec /usr/bin/open "#{opt_prefix}/RigWatch.app" --args "$@"
    SH
  end

  def caveats
    <<~EOS
      Start RigWatch with:
        rigwatch

      The first run puts a copy of RigWatch in ~/Applications, so Spotlight and
      Launchpad find it. After `brew upgrade`, reopening RigWatch updates that copy.
    EOS
  end

  test do
    app = prefix/"RigWatch.app"
    assert_path_exists app/"Contents/MacOS/RigWatch"
    assert_match "dev.rigwatch.RigWatch", (app/"Contents/Info.plist").read
    system "/usr/bin/codesign", "--verify", app
  end
end
