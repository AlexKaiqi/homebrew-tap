class Secrets < Formula
  desc "Manage Infisical secrets and inject them without a local value cache"
  homepage "https://github.com/AlexKaiqi/homebrew-tap"
  url "https://github.com/AlexKaiqi/homebrew-tap/releases/download/secrets-v0.1.3/secrets-0.1.3.tar.gz"
  sha256 "15758ab39abdb187c2bbee915915ff61da2cc6baa9ed00aaf7751469a8385186"

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
    libexec.install "vars", "management.py", "test_vars.py", "test_management.py"
    python = formula_opt_bin("python@3.14")/"python3.14"
    inreplace libexec/"vars", "#!/usr/bin/env python3", "#!#{python}"
    resource("infisical").stage do
      (libexec/"infisical").install "infisical"
      (pkgshare/"infisical").install "LICENSE" if File.exist?("LICENSE")
    end
    (bin/"vars").write_env_script libexec/"vars",
                                PATH: "#{libexec}/infisical:$PATH"
    pkgshare.install "CAPABILITY.md", "interface"
  end

  def caveats
    <<~EOS
      Authenticate this Mac: vars login
      Select your existing variable space:
        vars configure --project=PROJECT_ID --env=dev --path=/
      Start a program with its required variables:
        vars run --require=API_KEY -- python3 app.py
      Command help: vars --help or vars run --help
      Usage documentation: #{pkgshare}/CAPABILITY.md

      Authentication stays in macOS Keychain. Business secret values are not cached.
      Uninstalling keeps your session and location settings. Use vars logout first
      if you also want to remove this device's login.
    EOS
  end

  test do
    assert_equal "vars 0.1.3", shell_output("#{bin}/vars --version").strip
    assert_match "get", shell_output("#{bin}/vars --help")
    assert_match "0.43.137", shell_output("#{libexec}/infisical/infisical --version")
    with_env("HOME" => testpath.to_s, "PATH" => "/usr/bin:/bin") do
      assert_equal "signed_out", JSON.parse(shell_output("#{bin}/vars status --json", 3)).fetch("state")
    end
    system formula_opt_bin("python@3.14")/"python3.14", "-B", "-m", "unittest", "discover",
           "-s", libexec, "-p", "test_*.py"
  end
end
