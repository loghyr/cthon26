<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# This project has moved

**Continued as [loghyr/nfs-conformance](https://github.com/loghyr/nfs-conformance).**

cthon26 is no longer maintained.  All active development, new tests,
bug fixes, and documentation for the modern NFS / POSIX conformance
test suite are at the new repository:

> **https://github.com/loghyr/nfs-conformance**

The new project is a clean, standalone suite — it does not claim
lineage from the Connectathon NFS Testsuite (cthon04).  For the
historical cthon04 tree, see the dormant upstream at
`git://git.linux-nfs.org/projects/steved/cthon04.git`.

## History

The cthon26 repository history remains available in the git log of
this repository for reference.  The active `op_*` tests that used
to live in `nfsv42-tests/` (plus the xfstests bridge) were extracted
with history and rebased into `nfs-conformance`.  Subsequent
FreeBSD portability fixes made here have also been ported over.

## License

Everything under this repository remains available under
`BSD-2-Clause OR GPL-2.0-only` at the recipient's option.  See the
replacement repository for the current LICENSE and NOTICE files.
