class RemoteVariables < Formula
  desc "Read individual Infisical variables without a local secret cache"
  homepage "https://github.com/AlexKaiqi/homebrew-tap"
  url "https://github.com/AlexKaiqi/homebrew-tap/releases/download/remote-variables-v0.1.0/remote-variables-0.1.0.tar.gz"
  sha256 "ad2e9ab448753f994c6266ec641841b3e272b3ab46c8df821694cf2c45689ae4"

  depends_on "infisical/get-cli/infisical"
  depends_on :macos
  depends_on "python@3.14"

  def install
    libexec.install "scripts/vars", "scripts/test_vars.py"
    python = formula_opt_bin("python@3.14")/"python3.14"
    inreplace libexec/"vars", "#!/usr/bin/env python3", "#!#{python}"
    (bin/"vars").write_env_script libexec/"vars",
                                PATH: "#{formula_opt_bin("infisical/get-cli/infisical")}:$PATH"
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
    assert_equal "vars 0.1.0", shell_output("#{bin}/vars --version").strip
    assert_match "get", shell_output("#{bin}/vars --help")
    system formula_opt_bin("python@3.14")/"python3.14", "-B", "-m", "unittest", "discover",
           "-s", libexec, "-p", "test_vars.py"
  end
end
