<!--
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# cthon04 license

SPDX-License-Identifier: `BSD-2-Clause OR GPL-2.0-only`

Unless a specific file contains a notice to the contrary, the source
code in this repository is dual-licensed: a recipient may use it
under the terms of **either** the BSD 2-Clause License (below) **or**
the GNU General Public License, version 2 only (GPL-2.0-only,
available at <https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt>).

This is a proposal.  Historical files in this tree carry SCCS tags
identifying them as "Connectathon Testsuite" and, in older cases,
"Lachman ONC Test Suite source", but there is currently no explicit
license file.  The intent of adding this LICENSE.md -- pending
rightsholder approval -- is to give downstream consumers an
unambiguous answer to the question "under what terms may I use,
redistribute, or modify cthon04?"

## Why dual BSD-2-Clause / GPL-2.0-only

cthon04 has historically been consumed both by:

- **GPLv2 projects** -- the Linux kernel, `nfs-utils`, `nfsd`,
  `tlshd`, `ktls-utils`, and other distribution-shipped NFS tooling
  -- which cannot link against or distribute Apache-2.0, GPLv3, or
  AGPLv3 code without a compatibility waiver; and

- **permissive-licensed projects** -- FreeBSD's NFS stack, Solaris /
  illumos, macOS's NFS client, and a long tail of proprietary NFS
  implementations that run cthon04 as a correctness test suite.

Single-licensing under GPL-2.0-only would satisfy (1) but make (2)
uncomfortable (BSD projects prefer not to depend on copyleft
tooling).  Single-licensing under BSD-2-Clause would satisfy (2) but
invite downstream forks to disappear into proprietary distributions
without any expectation of upstreaming.  Dual-licensing gives every
consumer a path and preserves the test suite's role as the shared
reference both camps run.

The closest precedent is the Linux kernel's eBPF headers and the
`linux/tools/include/uapi/` tree, which adopted dual
`GPL-2.0 WITH Linux-syscall-note OR BSD-2-Clause` (and variants) for
exactly this reason: some consumers need the header in a GPL-only
build, others need it in a BSD-only build, and the upstream project
did not want to pick a winner.

## Compatibility with existing source files

The source files currently in this tree carry Connectathon Testsuite
and Lachman ONC Test Suite provenance notices but do **not** carry
per-file SPDX identifiers.  This proposal intentionally does **not**
modify those headers, because doing so would require the agreement
of the original rightsholders (Sun Microsystems / Oracle, Lachman
Associates' successors, and the individual authors whose changes
followed).  When the project maintainers are satisfied that the
dual-license declaration is compatible with the project's history
and with any surviving contributor expectations, adding a per-file
SPDX identifier (`SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only`)
would make machine-readable tooling (REUSE, Fossology, ScanCode,
GitHub's license-detection heuristics) give the right answer.

## BSD 2-Clause License

Copyright (c) 1993-2003 Sun Microsystems, Inc.
Copyright (c) Lachman Associates
Copyright (c) individual contributors, as noted in each file's
SCCS / RCS / Git history.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

## GNU General Public License, version 2

The full text of GPL-2.0-only is available at:

<https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt>

Recipients choosing the GPL-2.0-only option should refer to that
text; this repository does not bundle a separate copy of it in this
proposal in order to keep the review diff small.  A subsequent
commit can add `GPL-2.0-only.txt` alongside this file if the
maintainers prefer the text to live in-tree.
