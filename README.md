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
- TAP13 output across both halves of the tree (Phase 1 — shipped):
  - Every `nfsv42-tests/op_*` binary emits per-case TAP when
    invoked with `NFSV42_TESTS_TAP=1` in the environment.
  - `nfsv42-tests/runtests --tap` aggregates the op_* suite into
    one meta-TAP stream.
  - `./cthon04-tap [group ...]` wraps the cthon04 groups
    (`basic/`, `general/`, `special/`, `lock/`) and emits one
    TAP result per group, with the group's full output captured
    as `#`-prefixed diagnostics.
  - Both streams feed `prove`, `tappy`, and any CI system that
    speaks TAP13.
- Forthcoming (Phase 2): an `xfstests-bridge/` that exposes every
  cthon26 test through the `xfstests` runner under the `nfs` group,
  giving the Linux filesystem-testing community drop-in access.

## Quick start

The cthon04 core, unchanged:

```
make
./runtests [-t basic | general | special | lock] [-d MOUNTPOINT]
```

The NFSv4.x tests:

```
cd nfsv42-tests
make
./runtests -d /path/to/nfsv4.2/mount
```

TAP13 across the whole tree:

```
# cthon04 groups as TAP, one result per group
./cthon04-tap -d /path/to/nfs/mount

# NFSv4.x syscall-level tests as TAP, one result per case
./nfsv42-tests/runtests --tap -d /path/to/nfs/mount

# Parallel via prove (nfsv42-tests side; cthon04 groups have
# internal ordering dependencies and stay serial)
(cd nfsv42-tests && make check-prove JOBS=$(nproc))
```

See [`nfsv42-tests/README.md`](nfsv42-tests/README.md) for NFSv4.x
mount preparation, Kerberos setup, TLS, and interpreting `NOTE:`
lines reported by the newer tests.

## Documentation

- [`docs/tap.md`](docs/tap.md) — deep-dive guide to running cthon26
  with TAP13 output.  Covers the three entry points
  (`NFSV42_TESTS_TAP=1`, `runtests --tap`, `prove -j N`), plus
  `cthon04-tap`, CI integration examples (GitHub Actions, GitLab
  CI, Jenkins), and troubleshooting.
- [`docs/xfstests.md`](docs/xfstests.md) — deep-dive guide to
  running cthon26 under the `xfstests` / `fstests` harness via
  the `xfstests-bridge/`.  Covers installation (copy vs symlink),
  `local.config` setup, Kerberos/TLS mounts, debugging failures
  via `.out.bad` and `.full`, contributing new wrappers, and the
  path to upstream submission.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution rules,
  including the kernel-style `Assisted-by:` trailer for
  AI-assisted commits.
- [`nfsv42-tests/README.md`](nfsv42-tests/README.md) — per-test
  descriptions and environmental NOTEs (chown/idmap, Kerberos,
  renameat2 passthrough, `-m` strict mountstats).
- [`xfstests-bridge/README.md`](xfstests-bridge/README.md) — quick
  install and run for the xfstests bridge.

## Directory layout

```
cthon26/
  README.md            ← this file
  README               ← original cthon04 README (2003); still accurate for basic/, general/, special/, lock/
  LICENSE.md           ← dual BSD-2-Clause OR GPL-2.0-only (proposed)
  CONTRIBUTING.md      ← contribution rules, including AI-assistance attribution
  basic/ general/ special/ lock/   ← cthon04 test groups, unchanged
  server/ tools/       ← cthon04 support code
  runcthon, runtests   ← cthon04 drivers (unchanged)
  cthon04-tap          ← TAP13 wrapper for cthon04 test groups
  nfsv42-tests/        ← modern NFSv4.x syscall-level tests (imported as a
                         subtree; see its own README for test details and
                         the NFSV42_TESTS_TAP env var)
  xfstests-bridge/     ← xfstests-compatible wrappers for every
                         nfsv42-tests binary (tests 900-928)
  docs/                ← deep-dive guides (TAP, xfstests)
  .github/workflows/   ← GitHub Actions CI (three path-filtered workflows:
                         nfsv42-tests, cthon04, xfstests-bridge)
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
