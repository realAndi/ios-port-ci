# ios-port-ci

Shared publishing machinery for the iOS ports served from
[reallyitsandi.com/repo/](https://reallyitsandi.com/repo/).

A port repository decides *what it ships*. This one decides *how it gets
published*: assemble the `.deb`, generate and sign the APT index, carry old
versions forward, deploy to GitHub Pages. Read **[CONTRACT.md](CONTRACT.md)**
for the three scripts a port has to provide.

Ports using it:

| port | package |
|---|---|
| [gh-port](https://github.com/realAndi/gh-port) | `com.andi.github-cli` |
| [CCForiOS](https://github.com/realAndi/CCForiOS) | `com.andi.claude-code-native` |

## Why this exists

The two ports started as copies of each other: the same 146-line workflow, the
same `make-repo.py`, the same `fetch-published.sh`, diverging slowly. The cost
shows up the first time something has to change everywhere at once — a
deprecated runner action, a hardening step, a new field in `Release`. Applying
that N times and forgetting the N+1th is how a repository quietly stops being
signed.

Actions are pinned to commit SHAs rather than tags. A tag is mutable, and these
workflows hold a package-signing key.

## Versioning

Ports pin `@v1`. Breaking the contract means moving that tag deliberately, not
by pushing to `main`.
