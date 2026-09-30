class Secrets < Formula
  desc "Manage Infisical secrets and inject them without a local value cache"
  homepage "https://github.com/AlexKaiqi/homebrew-tap"
  url "https://github.com/AlexKaiqi/homebrew-tap/releases/download/secrets-v0.2.0/secrets-0.2.0.tar.gz"
  sha256 "f10d174e6d6b2ad887fcfcd72c30cb1ef56638b146f61253b18e15a62f021bf3"

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
    libexec.install "secrets", "management.py", "test_secrets.py", "test_management.py"
    python = formula_opt_bin("python@3.14")/"python3.14"
    inreplace libexec/"secrets", "#!/usr/bin/env python3", "#!#{python}"
    resource("infisical").stage do
      (libexec/"infisical").install "infisical"
      (pkgshare/"infisical").install "LICENSE" if File.exist?("LICENSE")
    end
    (bin/"secrets").write_env_script libexec/"secrets",
                                PATH: "#{libexec}/infisical:$PATH"
    pkgshare.install "CAPABILITY.md", "interface"
  end

  def caveats
    <<~EOS
      Authenticate this Mac: secrets login
      Select your existing variable space:
        secrets configure --project=PROJECT_ID --env=dev --path=/
      Start a program with its required variables:
        secrets run --require=API_KEY -- python3 app.py
      Command help: secrets --help or secrets run --help
      Usage documentation: #{pkgshare}/CAPABILITY.md

      Authentication stays in macOS Keychain. Business secret values are not cached.
      Uninstalling keeps your session and location settings. Use secrets logout first
      if you also want to remove this device's login.
    EOS
  end

  test do
    assert_equal "secrets 0.2.0", shell_output("#{bin}/secrets --version").strip
    assert_match "get", shell_output("#{bin}/secrets --help")
    assert_match "0.43.137", shell_output("#{libexec}/infisical/infisical --version")
    with_env("HOME" => testpath.to_s, "PATH" => "/usr/bin:/bin") do
      assert_equal "signed_out", JSON.parse(shell_output("#{bin}/secrets status --json", 3)).fetch("state")
    end
    system formula_opt_bin("python@3.14")/"python3.14", "-B", "-m", "unittest", "discover",
           "-s", libexec, "-p", "test_*.py"
  end
end
