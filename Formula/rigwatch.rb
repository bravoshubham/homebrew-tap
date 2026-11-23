class Rigwatch < Formula
  desc "Mission control for a developer's Mac: agents, emulators, builds and caches"
  homepage "https://github.com/bravoshubham/rigwatch"
  url "https://github.com/bravoshubham/rigwatch/archive/refs/tags/v1.11.17.tar.gz"
  sha256 "de81f23fd6423cb723d75d995910c214f2b1654ddf269d3b1b6444c6c8946c43"
  license "MIT"
  head "https://github.com/bravoshubham/rigwatch.git", branch: "main"

  # Built on Apple silicon for macOS 14 (the app's minimum), so newer macOS pours it too and needs no Xcode.
  bottle do
    root_url "https://github.com/bravoshubham/rigwatch/releases/download/v1.11.17"
    sha256 arm64_sonoma: "c4d0153d58b02ea8dfeddec414ba4d5aabce6797569c1301b42fa1d6aedf9d7c"
  end


  depends_on macos: :sonoma

  def install
    # Built here from source, so the app carries no quarantine flag and Gatekeeper does not block it.
    ENV["RIGWATCH_APP"] = (prefix/"RigWatch.app").to_s
    ENV["RIGWATCH_SWIFT_FLAGS"] = "--disable-sandbox"
    system "./bundle.sh"

    # Rules commands run the program directly, so their output reaches the terminal. They use the copy
    # in ~/Applications when it is at least this build: its path never changes, so a hook or clean-up
    # agent installed from it keeps working after `brew upgrade`. Anything else opens the app.
    (bin/"rigwatch").write <<~SH
      #!/bin/bash
      brew_app="#{opt_prefix}/RigWatch.app"
      copy="$HOME/Applications/RigWatch.app"
      build() { /usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$1/Contents/Info.plist" 2>/dev/null || echo 0; }
      case "$1" in
        run|hook|mcp|peer|reap|status|wt|pin|unpin|answer|install|uninstall|help|version|--version|iphone|progress)
          if [ -x "$copy/Contents/MacOS/RigWatch" ] && [ "$(build "$copy")" -ge "$(build "$brew_app")" ]; then
            exec "$copy/Contents/MacOS/RigWatch" "$@"
          fi
          if [ "$1" = install ]; then
            echo "Run 'rigwatch' once first: it puts an up-to-date RigWatch in ~/Applications, which the rules run from." >&2
            exit 1
          fi
          exec "$brew_app/Contents/MacOS/RigWatch" "$@" ;;
      esac
      exec /usr/bin/open "$brew_app" --args "$@"
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
