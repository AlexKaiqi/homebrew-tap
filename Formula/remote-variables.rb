class RemoteVariables < Formula
  desc "Read individual Infisical variables without a local secret cache"
  homepage "https://github.com/AlexKaiqi/homebrew-tap"
  url "https://github.com/AlexKaiqi/homebrew-tap/releases/download/remote-variables-v0.1.1/remote-variables-0.1.1.tar.gz"
  sha256 "ad0ffd74596744ef6694a2bdb66c1325a6f50b9ea491b610e12550d148b2caa8"

  depends_on :macos
  depends_on "python@3.14"

  resource "infisical" do
    on_arm do
      url "https://github.com/Infisical/cli/releases/download/v0.43.137/cli_0.43.137_darwin_arm64.tar.gz"
      sha256 "05a16daab6812de642fb1071d28a839088f204e9d4d3a0072fa5a7fc938c0d03"
    end
    on_intel do
      url "https://github.com/Infisical/cli/releases/download/v0.43.137/cli_0.43.137_darwin_amd64.tar.gz"
      sha256 "134a2db5382ec62ab8c51d3aba885acba6475b4444f0e0c3f58adfdd0b28328c"
    end
  end

  def install
    libexec.install "scripts/vars", "scripts/test_vars.py"
    python = formula_opt_bin("python@3.14")/"python3.14"
    inreplace libexec/"vars", "#!/usr/bin/env python3", "#!#{python}"
    resource("infisical").stage do
      (libexec/"infisical").install "infisical"
      (pkgshare/"infisical").install "LICENSE" if File.exist?("LICENSE")
    end
    (bin/"vars").write_env_script libexec/"vars",
                                PATH: "#{libexec}/infisical:$PATH"
    pkgshare.install "SKILL.md", "references", "agents"
  end

  def caveats
    <<~EOS
      Authenticate this Mac: vars login
      Select your existing variable space:
        vars configure --project=PROJECT_ID --env=dev --path=/
      Read a value into a consumer: vars get NAME

      Authentication stays in macOS Keychain. Business secret values are not cached.
      Uninstalling keeps your session and location settings. Use vars logout first
      if you also want to remove this device's login.
    EOS
  end

  test do
    assert_equal "vars 0.1.1", shell_output("#{bin}/vars --version").strip
    assert_match "get", shell_output("#{bin}/vars --help")
    assert_match "0.43.137", shell_output("#{libexec}/infisical/infisical --version")
    with_env("HOME" => testpath.to_s, "PATH" => "/usr/bin:/bin") do
      assert_equal "signed_out", JSON.parse(shell_output("#{bin}/vars status --json", 3)).fetch("state")
    end
    system formula_opt_bin("python@3.14")/"python3.14", "-B", "-m", "unittest", "discover",
           "-s", libexec, "-p", "test_vars.py"
  end
end
