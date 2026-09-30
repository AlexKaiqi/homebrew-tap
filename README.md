# Personal Homebrew packages

## Secrets

Install the macOS command and its dependencies:

```sh
brew install AlexKaiqi/tap/secrets
vars login
vars configure --project=PROJECT_ID --env=dev --path=/
```

Use your existing Infisical project ID. Each device authenticates independently in the browser.
Homebrew installs Python and includes a pinned official Infisical CLI inside the package.
No separate Infisical Tap, global Infisical command, Agent, or skill installer is required.

Fetch a value when a program needs it:

```sh
(
  API_KEY="$(vars get API_KEY)" || exit "$?"
  export API_KEY
  exec python3 app.py
)
```

Replace the example variable and program with your own. The value is plaintext on stdout;
send it directly to the consuming program and keep shell tracing disabled.
Each request reads only the named variable, without writing a business-secret cache.
Authentication credentials remain in macOS Keychain; project location settings remain local.

Upgrade or uninstall:

```sh
brew update
brew upgrade AlexKaiqi/tap/secrets
vars --version
brew uninstall secrets
```

Uninstalling preserves your session and location settings. To remove this device's session,
run `vars logout` before uninstalling. Existing process environments are not revoked by logout.

This package currently supports macOS. Every [release](https://github.com/AlexKaiqi/homebrew-tap/releases)
includes the versioned source archive, tests, usage documentation and SHA-256 checksum.
The formula is generated from that source; credentials and personal configuration are never bundled.
