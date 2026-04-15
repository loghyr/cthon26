<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# AGENTS.md — guidance for AI coding assistants in cthon26

This file is read by AI coding assistants (Claude, Codex, Gemini,
Cursor, and any future entrant) when they operate on this repository.
Human contributors: see [`CONTRIBUTING.md`](CONTRIBUTING.md) for the
submission workflow; the section **"The cthon04 preservation rule"**
there mirrors the critical rule below.

cthon26 is a careful refresh of the 1986-era Connectathon NFS
Testsuite (cthon04) plus modern NFSv4.x syscall-level tests
(nfsv42-tests).  The cthon04 portion is portable across AIX, HP-UX,
Solaris, Tru64, BSD, macOS, and Linux; it has shipped without a
meaningful upstream break for more than three decades.  That
portability is the project's most valuable asset.  It is also the
single thing an unsupervised AI agent is most likely to destroy by
"improving" something.

## CRITICAL: The cthon04 preservation rule

**Do not modify files in the cthon04 core unless the user asks you
to, in this session, with specific scope, and you have verified the
change is also acceptable upstream at
`git://git.linux-nfs.org/projects/steved/cthon04.git`.**

The "cthon04 core" is every file and directory that existed in the
`proposed/dual-license` branch of cthon04 before cthon26 added its
own contributions.  Concretely:

| Path | Status |
|------|--------|
| `basic/` | cthon04 core — do not modify |
| `general/` | cthon04 core — do not modify |
| `special/` | cthon04 core — do not modify |
| `lock/` | cthon04 core — do not modify |
| `server/` | cthon04 core — do not modify |
| `tools/` | cthon04 core — do not modify |
| `Makefile` | cthon04 core — do not modify |
| `runtests` (top-level) | cthon04 core — do not modify |
| `runcthon` | cthon04 core — do not modify |
| `tests.init`, `tests.init.sh` | cthon04 core — do not modify |
| `tests.h` (top-level) | cthon04 core — do not modify |
| `domount.c` | cthon04 core — do not modify |
| `getopt.c` | cthon04 core — do not modify |
| `unixdos.h` | cthon04 core — do not modify |
| `cthon04.spec` | cthon04 core — do not modify |
| `Testitems` | cthon04 core — do not modify |
| `README` (without .md) | cthon04 core — do not modify |
| `READWIN.txt` | cthon04 core — do not modify |
| `LICENSE.md` | cthon04 core — do not modify without a license-change task |
| `GPL-2.0-only.txt` | cthon04 core — do not modify |

### Why this rule is non-negotiable

1. **Portability is the point.**  cthon04 runs unchanged on AIX 5.3,
   HP-UX 11i, Solaris 10, Tru64, FreeBSD, NetBSD, OpenBSD, macOS 10.x
   through 13.x, and every Linux distribution from RHEL 5 forward.
   You do not have those platforms in your execution environment.
   Any change that "clearly" works on Linux or macOS has a material
   chance of breaking a platform you cannot test.

2. **The DOS/Windows scaffolding is not dead code.**  `unixdos.h`,
   `READWIN.txt`, the `#ifdef WIN32` branches, and the `DOSorWIN32`
   conditional in `tests.h` look obsolete but belong to a
   historically-working port.  Do not delete them.

3. **SCCS-style headers and comment styles are load-bearing.**  The
   `@(#)foo.c  1.7 2003/12/01 Connectathon Testsuite` string in every
   cthon04 file identifies upstream provenance.  Do not "clean it
   up" or replace it with an SPDX header unless the user explicitly
   requests a license-update task (see `LICENSE.md`: "pending
   rightsholder approval").

4. **Exit codes and output strings are a public contract.**  External
   CI systems grep for `"Starting BASIC tests"` or read specific exit
   codes from `basic/runtests`.  Do not rewrite the driver flow.

5. **Upstream is authoritative.**  If a bug is real, fix it in Steve
   Dickson's tree first and let cthon26 inherit the fix via a
   re-import or cherry-pick.  Local drift from upstream creates
   maintenance debt that harms both trees.

6. **Running `clang-format` or equivalent over the tree would be
   catastrophic.**  Every cthon04 file would be reformatted, making
   the delta against upstream unreadable.  Do not do this even as
   "part of a separate commit."  If style normalization is ever in
   scope, it happens upstream at Steve's tree, then flows here.

### What IS allowed on the cthon04 core

Narrow exceptions, each requiring explicit user consent in the
current session:

- Fixing a genuine build regression on a platform the tree is
  supposed to work on, with a minimal patch that upstream would
  accept.  Post the patch to upstream first; inherit the fix.
- Adding a small cross-reference comment (e.g., "see nfsv42-tests/
  for the modern replacement") if the user explicitly requests it.
- A re-import / cherry-pick from upstream to pull a new fix in.

All three are rare.  Default to **"do not modify"**.

### If you think the rule is wrong, STOP

Do not silently refactor.  Raise the concern to the user, explain
what you want to change and why, wait for explicit approval, and
record the approval in the commit message so future reviewers
understand the exception.

## Where new cthon26 work goes

Freely (subject to the usual review):

| Path | What lives there |
|------|------------------|
| `nfsv42-tests/` | Modern NFSv4.x syscall-level tests. |
| `xfstests-bridge/` | xfstests wrappers and helpers. |
| `cthon04-tap` | TAP13 wrapper over the cthon04 groups.  This file IS new and is cthon26's to edit. |
| `runcthon26` | Unified driver running both halves.  New, cthon26-owned. |
| `docs/` | Deep-dive guides (TAP, xfstests). |
| `.github/workflows/` | CI workflows. |
| `README.md` | Top-level cthon26 framing.  Explicitly ours, not cthon04's. |
| `CONTRIBUTING.md` | Contribution rules. |
| `AGENTS.md` | This file. |

New top-level files are acceptable if they begin with an SPDX
header and do not shadow or replace a cthon04-core file.

## Commit-message conventions

Every AI-assisted commit must carry:

```
Assisted-by: AGENT_NAME:MODEL_VERSION
Signed-off-by: Human Name <human@email>
```

per the kernel's
[coding-assistants policy](https://docs.kernel.org/process/coding-assistants.html).
AI agents must NOT add `Signed-off-by:` lines.  The human submitter
certifies the DCO.  `git commit -s` adds `Signed-off-by:`
automatically.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full wording.

## Tool-specific pointers

- **Claude Code**: the harness auto-loads `CLAUDE.md` if present.
  This repo uses `AGENTS.md` as the canonical guidance; if your
  tooling prefers `CLAUDE.md`, it should be a stub pointing here.
- **Codex / Cursor / Gemini**: read this file directly before
  operating.  The cthon04 preservation rule applies regardless of
  which agent is active.

## Reading order

When you land in this repo, read in this order before touching
anything:

1. `AGENTS.md` (this file) — the rules.
2. `README.md` — what the project is.
3. `CONTRIBUTING.md` — how contributions flow.
4. The directory-specific README for whatever you're about to
   edit.
5. `docs/tap.md` and `docs/xfstests.md` if the task touches TAP
   output or the xfstests bridge.

Do not proceed to edits until you have read those and understood
the cthon04 preservation rule.
