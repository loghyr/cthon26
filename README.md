<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# cthon26 — Connectathon NFS Testsuite, 2026 refresh

This is a continuation of the Connectathon NFS Testsuite that Sun
Microsystems and the NFS Connectathon community shipped from 1986 to
2004.  The original tree (the `basic/`, `general/`, `special/`, and
`lock/` directories, with the `runtests`, `runcthon`, and
`server/` scaffolding) is preserved verbatim from cthon04's
`proposed/dual-license` branch.

cthon26 adds:

- `nfsv42-tests/` — syscall-level tests for NFSv4, NFSv4.1, and
  NFSv4.2 operations that post-date cthon04's active maintenance
  (RFC 5661, RFC 7530, RFC 7862, RFC 8276, RFC 9289).  See
  [`nfsv42-tests/README.md`](nfsv42-tests/README.md) for the full
  test matrix.
- A dual license: `BSD-2-Clause OR GPL-2.0-only` on all new files;
  inherited cthon04 files keep their existing Connectathon and
  Lachman SCCS headers, covered by the top-level `LICENSE.md`
  (pending rightsholder approval per the proposal note).
- Forthcoming (Phase 1): a unified TAP13-based harness so every
  test emits `ok`/`not ok`/`# SKIP` lines consumable by `prove`,
  `tappy`, and any CI system that speaks TAP.
- Forthcoming (Phase 2): an `xfstests-bridge/` that exposes every
  cthon26 test through the `xfstests` runner under the `nfs` group,
  giving the Linux filesystem-testing community drop-in access.

## Quick start

Identical to cthon04 for now:

```
make
./runtests [-t basic | general | special | lock] [-d MOUNTPOINT]
```

For the NFSv4.x tests:

```
cd nfsv42-tests
make
./runtests -d /path/to/nfsv4.2/mount
```

See [`nfsv42-tests/README.md`](nfsv42-tests/README.md) for NFSv4.x
mount preparation, Kerberos setup, TLS, and interpreting `NOTE:`
lines reported by the newer tests.

## Directory layout

```
cthon26/
  README.md            ← this file
  README               ← original cthon04 README (2003); still accurate for basic/, general/, special/, lock/
  LICENSE.md           ← dual BSD-2-Clause OR GPL-2.0-only (proposed)
  CONTRIBUTING.md      ← contribution rules, including AI-assistance attribution
  basic/ general/ special/ lock/   ← cthon04 test groups, unchanged
  server/ tools/       ← cthon04 support code
  runcthon, runtests   ← cthon04 drivers; TAP adapter planned in Phase 1
  nfsv42-tests/        ← modern NFSv4.x syscall-level tests (imported as a
                         subtree; see its own README for test details)
```

## Relationship to upstream cthon04

cthon04 lives at `git://git.linux-nfs.org/projects/steved/cthon04.git`
and remains the canonical place for fixes to the cthon04 core.
cthon26 cherry-picks the `proposed/dual-license` branch of that
tree and adds the modern tests on top.  Changes that affect the
cthon04 core should be proposed to both trees.

## Status

cthon26 is an active refresh.  Interfaces will move over the next
few releases.  See `CONTRIBUTING.md` for how to help and the
attribution rules (including the kernel-style `Assisted-by:`
trailer for AI-assisted work).
