<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# Claude Code instructions for cthon26

The canonical AI-agent guidance for this repository lives in
[`AGENTS.md`](AGENTS.md).  Read that file before touching anything.

Highlights, so the rule is visible even if you skim:

1. **Do not modify the cthon04 core** — `basic/`, `general/`,
   `special/`, `lock/`, `server/`, `tools/`, and the top-level
   cthon04 drivers (`Makefile`, `runtests`, `runcthon`,
   `tests.init*`, `tests.h`, `domount.c`, `getopt.c`, `unixdos.h`,
   `cthon04.spec`, `Testitems`, `README`, `READWIN.txt`,
   `LICENSE.md`, `GPL-2.0-only.txt`).  These files ship unchanged
   across AIX, HP-UX, Solaris, Tru64, BSD, macOS, and Linux, and
   downstream CI grep-parses their output.  See `AGENTS.md` for
   the full explanation and the narrow exceptions.

2. **Commits must carry the kernel `Assisted-by:` trailer** but
   never `Signed-off-by:` from the AI.  See `CONTRIBUTING.md`.

3. **Reading order when you arrive**: `AGENTS.md`, then
   `README.md`, then `CONTRIBUTING.md`, then the relevant
   subdirectory README, then `docs/tap.md` or `docs/xfstests.md`
   if the task touches TAP or the xfstests bridge.

Everything else — architecture, directory layout, how to run the
suite — is in `README.md` and the `docs/` tree.
