# NOTICE

This distribution packages and simplifies installation of **ai-memory**, an
open-source project by akitaonrails:

- Project: https://github.com/akitaonrails/ai-memory
- License: MIT License
- Release: 3.1.1 (this distro always pulls the latest upstream release at
  install time)

ai-memory itself is **not** modified, vendored, or re-licensed by this distro.
The installers in this repo download the official upstream release binaries
published on the ai-memory GitHub Releases page, verify them through the
upstream installers' own SHA-256 checksum checks, and then run the upstream
setup step scoped to Cursor (`ai-memory setup --agent cursor --yes`).

The install scripts and documentation in this repo are original work by
Funapp (Kyaw Myo Naing) and are provided under the MIT License (see `LICENSE`).

The full MIT license text of ai-memory is available at:
https://github.com/akitaonrails/ai-memory/blob/main/LICENSE

Note: the ai-memory program installed by the scripts in this repo is a
separate work (c) akitaonrails, also MIT-licensed. It is covered by this
NOTICE, not by this repo's LICENSE file.
