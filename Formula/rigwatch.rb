class Rigwatch < Formula
  desc "Mission control for a developer's Mac: agents, emulators, builds and caches"
  homepage "https://github.com/bravoshubham/rigwatch"
  url "https://github.com/bravoshubham/rigwatch/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "0ace6dc3b4f692878d26289b933e01cd77200636f3a0c51ec335ebbe21d0bc49"
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

      To also find it in your Applications folder:
        ln -sfn "#{opt_prefix}/RigWatch.app" ~/Applications/RigWatch.app
    EOS
  end

  test do
    app = prefix/"RigWatch.app"
    assert_path_exists app/"Contents/MacOS/RigWatch"
    assert_match "dev.rigwatch.RigWatch", (app/"Contents/Info.plist").read
    system "/usr/bin/codesign", "--verify", app
  end
end
