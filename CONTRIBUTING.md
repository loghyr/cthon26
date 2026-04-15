<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# Contributing to cthon26

Contributions follow the Linux kernel's Developer Certificate of
Origin (DCO) workflow and, for AI-assisted work, the kernel's
coding-assistants policy.

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
