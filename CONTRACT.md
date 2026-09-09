# The port contract

A repository that packages something for jailbroken iOS is responsible for
*what it ships*. This repository is responsible for *how it gets published*.
The line between them is three scripts and a few files.

## What your port must provide

| path | runs on | responsibility |
|---|---|---|
| `tools/resolve-version.sh [wanted]` | Linux | Echo the upstream version to build. With an argument, validate and echo that; without, discover the current one. Nothing else on stdout. |
| `tools/build-payload.sh <version>` | macOS | Produce everything the package will contain, into `packaging/payload/`. Write `packaging/payload/PAYLOAD.version` whose first field is the version. |
| `tools/build-deb.sh [revision]` | Linux | Assemble `repo/debs/<pkg>_<version>-<revision>_iphoneos-arm64.deb` from that payload. |

Plus `packaging/revision`, `packaging/DEBIAN/{control.in,postinst,prerm}`,
`packaging/depiction.json`, `packaging/index.html`, and `assets/icon.png`.

The depiction is the Sileo/Zebra native JSON format, not HTML: both managers
render it as real UI instead of a web view, and both read it from a
`Native-Depiction:` field in the package's control. It is validated as JSON
during publish, because a malformed one renders as a blank page rather than an
error. A port may also ship `packaging/depiction.html`, which is copied
alongside for Cydia and the repo-listing sites; nothing requires it.

The split is deliberate. Building the payload is the only step that needs a
macOS runner — an iPhoneOS SDK, `ldid`, Xcode — and it is the only step that
differs fundamentally between ports: one compiles Go for `ios/arm64`, another
downloads a proprietary binary and patches its Mach-O. Assembling a `.deb` and
publishing an APT index are the same job every time, so they live here.

## What this repository provides

`.github/workflows/publish.yml` is a reusable workflow. Your port's own
`publish.yml` shrinks to a call:

```yaml
jobs:
  publish:
    uses: realAndi/ios-port-ci/.github/workflows/publish.yml@v1
    with:
      package: com.andi.example
      origin: example-port
      label: Example for iOS
      description: What the repository serves
    secrets:
      GPG_KEY: ${{ secrets.REPO_GPG_KEY }}
      GPG_KEY_ID: ${{ secrets.REPO_GPG_KEY_ID }}
```

It also provides shared tools, checked out at `.ci/tools/` during a run and
reachable as `$CI_TOOLS`:

| tool | for |
|---|---|
| `make-repo.py` | APT `Packages`/`Release`, GPG signing |
| `fetch-published.sh` | Carry already-published versions forward so rollback survives a rebuild |
| `check-macho.py` | Prove a Mach-O is really an iOS binary, signed, linking only libraries iOS has |
| `clangwrap.sh` | clang pointed at the iPhoneOS SDK |

For local development, `tools/ci.sh` in a port clones this repo to `.ci/`, so
the same scripts run on a laptop and on a runner.

## Why every port signs with its own key

`reallyitsandi.com` pins a fingerprint per source and refuses an index it
cannot verify. That check is worth nothing if every port shares one key: a
compromise of the least-exercised repository would forge indexes for all of
them. One key per port, held only in that port's Actions secrets, keeps the
blast radius to the repository that was actually breached.
