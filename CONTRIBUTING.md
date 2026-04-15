<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# Contributing to cthon26

Contributions follow the Linux kernel's Developer Certificate of
Origin (DCO) workflow and, for AI-assisted work, the kernel's
coding-assistants policy.

## The cthon04 preservation rule

**cthon26 treats the inherited cthon04 core as immutable by default.**

The "cthon04 core" is every file and directory that came from the
cthon04 `proposed/dual-license` branch: `basic/`, `general/`,
`special/`, `lock/`, `server/`, `tools/`, plus the top-level
drivers (`Makefile`, `runtests`, `runcthon`, `tests.init`,
`tests.init.sh`, `tests.h`, `domount.c`, `getopt.c`, `unixdos.h`,
`cthon04.spec`, `Testitems`, `README`, `READWIN.txt`, `LICENSE.md`,
`GPL-2.0-only.txt`).

cthon04 is portable across AIX, HP-UX, Solaris, Tru64, BSD, macOS,
and Linux.  That portability is the project's single most valuable
asset.  "Harmless" cleanups — formatting, removing `#ifdef WIN32`
blocks, replacing SCCS headers with SPDX-only headers, reorganising
output strings — have a real chance of breaking platforms no cthon26
developer currently tests.  External CI systems also grep for
specific cthon04 output strings; changing them breaks consumers
outside this repository.

Bug fixes and improvements to the cthon04 core belong upstream at
`git://git.linux-nfs.org/projects/steved/cthon04.git` first.
Downstream (cthon26) inherits the fix via a re-import or
cherry-pick.  Local drift from upstream creates maintenance debt
that harms both trees.

If you believe a cthon04 file genuinely needs editing in this tree,
please open an issue describing the problem and the smallest
possible fix before sending a PR.  Exceptions are rare.

New work — new tests, new harness code, new documentation — lives
in directories we own: `nfsv42-tests/`, `xfstests-bridge/`,
`cthon04-tap`, `docs/`, `.github/`, `README.md`, `CONTRIBUTING.md`,
`AGENTS.md`.  That boundary is the easy one to stay on the right
side of.

AI coding assistants have a matching directive in
[`AGENTS.md`](AGENTS.md).

## Developer Certificate of Origin (DCO)

Every commit must carry a real `Signed-off-by:` trailer from the
submitting developer.  `git commit -s` appends it automatically.
The trailer certifies the DCO text at
<https://developercertificate.org/>.

## AI-assisted contributions

cthon26 follows the Linux kernel's
[coding-assistants policy](https://docs.kernel.org/process/coding-assistants.html).
When a commit was authored with AI assistance, add an `Assisted-by:`
trailer in the form:

```
Assisted-by: AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]
```

For example:

```
Assisted-by: Claude:claude-sonnet-4-6
Assisted-by: Claude:claude-sonnet-4-6 coccinelle sparse
```

Rules, verbatim from the kernel policy:

- **AI agents MUST NOT add `Signed-off-by:` tags.**  Only the human
  submitter can certify the DCO.  The human is responsible for:
    - Reviewing all AI-generated code;
    - Ensuring compliance with licensing requirements;
    - Adding their own `Signed-off-by:` tag;
    - Taking full responsibility for the contribution.
- Only list AI tools that materially contributed.  Basic development
  tools (`git`, `gcc`, `make`, editors) are not listed.
- Purely human commits do not carry `Assisted-by:`.

## Historical position (pre-cthon26)

This tree's history includes two pre-cthon26 sources:

1. Commits inherited from cthon04 (`proposed/dual-license` branch
   and earlier) predate the AI-assistance convention.  Any AI
   involvement in those commits is documented in the cthon04
   upstream, not here.
2. Commits inherited from `nfsv42-tests` (imported as a subtree at
   `nfsv42-tests/`) predate cthon26 and are not retroactively
   tagged.  Many of those commits were authored with the assistance
   of Claude (Anthropic); that provenance is disclosed here rather
   than rewritten into history so the cthon04 and nfsv42-tests
   commit hashes stay stable for anyone who already pulled them.

From the first cthon26-owned commit onward, the `Assisted-by:`
trailer convention applies.

## Patch submission

Until a public cthon26 tree is established, proposals go through
the same place as cthon04 fixes: the linux-nfs mailing list and
Steve Dickson's tree at
`git://git.linux-nfs.org/projects/steved/cthon04.git`.  When
cthon26 has its own tree the pointers here will be updated.

## Coding style

- cthon04 core (`basic/`, `general/`, `special/`, `lock/`, `server/`,
  `tools/`): match the existing style.  That code has been portable
  across BSD / System V / Solaris since the 1980s; keep it so.
- `nfsv42-tests/`: follows its own `.clang-format`.  `make style`
  runs clang-format over the tree.

## Running the suite

See `README.md`.
