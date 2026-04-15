<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# Running cthon26 under xfstests

[xfstests](https://github.com/kdave/xfstests), also known as `fstests`,
is the de-facto filesystem conformance suite that the Linux filesystem
and NFS communities run every day.  It drives tests with a `check`
shell script, per-test `.out` golden-output comparison, rich
environmental gating (`_notrun`, `_require_*`), and group tags for
selecting subsets (`-g auto`, `-g nfs`, `-g quick`).

cthon26 ships a bridge under [`xfstests-bridge/`](../xfstests-bridge/)
that wraps every `nfsv42-tests` binary as one xfstests test in the
`nfs` group.  Once installed, a tester can run cthon26 alongside
their existing filesystem tests with `./check -nfs -g nfs`.

This document is the deep-dive reference.  For the quick install
recipe, see [`xfstests-bridge/README.md`](../xfstests-bridge/README.md).

## Why this exists

xfstests is where filesystem maintainers live day-to-day.  Red Hat,
SUSE, Oracle, and every Linux NFS vendor's CI pipeline already runs
xfstests against their builds.  The Linux NFS subsystem's `nfs`
group in xfstests is the primary location Chuck Lever, Jeff Layton,
and upstream maintainers look for NFS conformance signal.

Rather than asking them to learn a new runner, the bridge lets
cthon26 flow into the runner they already use.  Every cthon26 test
becomes `./check -nfs nfs/NNN`, every cthon26 SKIP becomes
`_notrun`, every cthon26 failure becomes an xfstests `.out.bad`
diff — idioms xfstests users recognise at a glance.

## The wrapper model

Each of cthon26's 29 `op_*` binaries has a corresponding ~25-line
shell wrapper at `xfstests-bridge/tests/nfs/NNN` plus a two-line
golden-output file at `xfstests-bridge/tests/nfs/NNN.out`.  The
wrapper runs the cthon26 binary, translates its `0/1/77/99` exit
code into xfstests idioms, and emits the standard `Silence is
golden.` line that xfstests' golden diff expects on pass.

The translation table:

| cthon26 exit | cthon26 meaning | Wrapper action | xfstests outcome |
|--------------|-----------------|----------------|-------------------|
| 0 | PASS | print `Silence is golden.` | matches `.out` → pass |
| 77 | SKIP | call `_notrun "<reason>"` | skip with reason |
| 1 | FAIL | echo captured output; exit 1 | golden diff fails → fail |
| 99 | BUG | echo captured output; exit 99 | golden diff fails → fail |

Test numbers are assigned starting at 900 because xfstests reserves
0-599 for upstream tests and 9xx for downstream / out-of-tree
additions.  Once the wrappers shake out, the intent is to propose
them upstream into the `tests/nfs/` tree of kdave/xfstests.

## Installation

### Prerequisites

- **xfstests build dependencies.**  xfstests' own C helpers
  require a long list of filesystem-development headers even
  when you only intend to run the `nfs` group.  Install them
  BEFORE `make`:

  ```
  # Fedora / RHEL / CentOS / Rocky
  sudo dnf install -y xfsprogs-devel e2fsprogs-devel \
       attr libattr-devel libacl-devel libuuid-devel gdbm-devel \
       libaio-devel openssl-devel gawk

  # Debian / Ubuntu
  sudo apt install -y xfslibs-dev libattr1-dev libacl1-dev \
       libaio-dev libgdbm-dev libuuid1 uuid-dev attr acl \
       quota xfsprogs libtool-bin libssl-dev gawk
  ```

  Symptom if missing:

  ```
  FATAL ERROR: cannot find a valid <xfs/xfs.h> header file.
  Run "make install-dev" from the xfsprogs source.
  ```

  That error message is misleading -- `make install-dev` inside
  the xfstests tree does nothing; you need the xfsprogs
  **headers package** from your distribution, not an xfsprogs
  re-install.

- A working xfstests checkout:
  ```
  git clone https://github.com/kdave/xfstests.git
  cd xfstests
  make          # builds the framework's C helpers; requires the
                # dev headers installed above
  ```

- A built cthon26/nfsv42-tests:
  ```
  cd /path/to/cthon26/nfsv42-tests
  make
  ```

- An NFSv4.2 mount you can write to.  xfstests itself insists on
  a real mount for its NFS group; tmpfs smoke tests do not
  exercise the protocol at all.

### xfstests `local.config`

xfstests reads `local.config` (or a named config passed via
`./check -c NAME`) to find the mount to test against.  Minimum
viable config for cthon26:

```sh
# xfstests/local.config
export FSTYP=nfs
export TEST_DEV=server:/export
export TEST_DIR=/mnt/nfs42
# cthon26-specific:
export CTHON26_BIN=/path/to/cthon26/nfsv42-tests
```

`TEST_DEV` must be pre-mounted at `TEST_DIR`; xfstests will not
mount it for you in the NFS case.  If you also want tests that
need a scratch mount (none of the cthon26 wrappers currently do),
add `SCRATCH_DEV` and `SCRATCH_MNT`.

`CTHON26_BIN` is cthon26-specific: the wrappers look there for the
`op_*` binaries.  Defaults to `/usr/local/lib/cthon26`; override
for in-tree development.  If the binaries aren't found, every
cthon26 wrapper will `_notrun` with a message explaining the fix.

### Copy or symlink

Two install modes, both via `xfstests-bridge/install.sh`:

**Copy** (simplest; safe; re-run after each `git pull`):
```
/path/to/cthon26/xfstests-bridge/install.sh /path/to/xfstests
```

**Symlink** (for cthon26 developers who want edits to take effect
without re-copying):
```
/path/to/cthon26/xfstests-bridge/install.sh --symlink /path/to/xfstests
```

Both modes copy/link `common/cthon26` into `xfstests/common/` and
every `tests/nfs/NNN[.out]` into `xfstests/tests/nfs/`.  They also
append a `cthon26` line to `xfstests/doc/group-names.txt` (if not
already present) — xfstests' build refuses to generate a group index
that references undocumented group tags.

After running `install.sh`, rebuild xfstests to regenerate the
per-directory `group.list`:

```
cd /path/to/xfstests && make
```

Without that rebuild, `./check -g cthon26` reports
`Group "cthon26" is empty or not defined?`.

Flags:
- `--dry-run`: print what would happen, don't touch anything.
- `--backup`: keep timestamped copies of any overwritten files.
- `--help`: usage.

The script refuses to run against a directory that doesn't look
like an xfstests checkout (missing `tests/nfs/` or `common/`).

## Running

### Full cthon26 suite

```
cd /path/to/xfstests
./check -nfs -g cthon26
```

Every cthon26 wrapper carries the `cthon26` group tag.  Filtering
on it selects ONLY the cthon26 tests, not the dozens of upstream
xfstests NFS tests that share `tests/nfs/`.

If you want both suites combined — cthon26 wrappers AND upstream
NFS coverage — use `-g nfs` instead.  That picks up every test
tagged `nfs` across the entire xfstests `tests/nfs/` directory,
including stress / long-running / multi-minute tests that are not
part of cthon26.  Expect several minutes of wall time.

### Fast subset

```
./check -nfs -g cthon26,quick
```

Intersection of `cthon26` and `quick`: cthon26 wrappers whose
underlying tests complete in well under a second each.  See the
test list in
[`xfstests-bridge/README.md`](../xfstests-bridge/README.md) for
which tests are tagged `quick`.

### Individual tests

```
./check -nfs nfs/904          # op_commit
./check -nfs nfs/907 nfs/908  # op_deleg_attr and op_deleg_read
```

### Run everything *except* cthon26

If you have the bridge installed but want a baseline without
cthon26 tests:

```
./check -nfs -x nfs/9xx
```

`-x` excludes matching tests.

### Expected output

xfstests' output is line-per-test with wall-time, group tags, and
a summary:

```
FSTYP         -- nfs
PLATFORM      -- Linux/x86_64 hs-124 6.8.0-fc39
MKFS_OPTIONS  --
MOUNT_OPTIONS -- -o vers=4.2,sec=sys

nfs/900   2s ...
nfs/901   3s ...
nfs/902   1s ...  [not run] cthon26 op_change_attr skipped (see stderr)
nfs/903   1s ...  [not run] cthon26 op_clone skipped (see stderr)
nfs/904   1s ...
...
Ran: nfs/900 nfs/901 nfs/902 nfs/903 nfs/904 ...
Not run: nfs/902 nfs/903
Passed all 27 tests
```

## Debugging a failing test

When a wrapper's `.out` diff fails, xfstests writes
`tests/nfs/NNN.out.bad` with what the wrapper actually printed.
Compare:

```
diff tests/nfs/904.out tests/nfs/904.out.bad
```

Typically this shows the cthon26 test's captured output that
didn't match `Silence is golden.`:

```
@@ -1,2 +1,5 @@
 QA output created by 904
-Silence is golden.
+TEST: op_commit: fsync/fdatasync -> NFSv4 COMMIT (RFC 7530 S18.3)
+FAIL: case3: chunk 2 mismatch at byte 100 (log-style fsync did not persist round)
+summary: 2 passed, 1 failed, 0 skipped, 0 missing, 0 bugs
```

From there:
1. The cthon26 `FAIL:` line tells you which `case_foo()` reported
   the defect.  Look at `nfsv42-tests/op_commit.c` for that case's
   logic.
2. Run the cthon26 binary directly with verbose output:
   `$CTHON26_BIN/op_commit -d $TEST_DIR` (no `-s`) shows per-case
   progress.
3. Or use TAP mode for machine-readable per-case results:
   `NFSV42_TESTS_TAP=1 $CTHON26_BIN/op_commit -d $TEST_DIR`.

### Preserving diagnostic artifacts

xfstests also writes `tests/nfs/NNN.full` containing any stderr
output the wrapper produced.  cthon26's `complain()` goes to
stderr in non-silent mode, but in the wrapper we redirect with
`2>&1` so failures end up in the golden diff.  You'll rarely need
`.full` for cthon26 wrappers; for other xfstests it's the first
place to look.

## Running against Kerberos and TLS mounts

cthon26 tests use whatever auth and transport security the mount
negotiates — they don't care.  Just mount with the options you
want to test:

```
# krb5 mount
kinit user@REALM
sudo mount -t nfs -o vers=4.2,sec=krb5 server:/export /mnt/krb5
export TEST_DIR=/mnt/krb5
./check -nfs -g nfs,quick

# TLS mount (RFC 9289)
sudo mount -t nfs -o vers=4.2,xprtsec=tls server:/export /mnt/tls
export TEST_DIR=/mnt/tls
./check -nfs -g nfs,quick
```

Same tests, different transport.  Interpreting
environment-specific NOTEs (chown EINVAL under idmap mismatch, xattr
not supported, etc.) is documented in
[`nfsv42-tests/README.md`](../nfsv42-tests/README.md) under
"Interpreting environmental NOTEs."

## Contributing a new wrapper

When you add a new cthon26 binary, follow this checklist to ship a
matching xfstests wrapper:

1. **Pick the next free test number.**  `ls
   xfstests-bridge/tests/nfs/ | sort -n | tail -1` shows the
   highest.  Use the next integer.

2. **Copy an existing simple wrapper** (e.g. `900`) as a template:
   ```
   cp xfstests-bridge/tests/nfs/900 xfstests-bridge/tests/nfs/929
   cp xfstests-bridge/tests/nfs/900.out xfstests-bridge/tests/nfs/929.out
   ```

3. **Update the wrapper**:
   - SPDX header (keep `BSD-2-Clause OR GPL-2.0-only`)
   - `FS QA Test No. NNN` line
   - Short description matching the cthon26 binary's purpose
   - `_begin_fstest GROUPS` — always include `auto nfs`; add
     `quick` if the test reliably completes in under ~1 second
     on a local mount
   - `_require_cthon26_binary NAME`
   - `_cthon26_run NAME` (or `_cthon26_run_args NAME -S server`
     if the test needs extra flags)

4. **Update `.out`**: change the test number on the `QA output
   created by NNN` line.  The second line stays `Silence is
   golden.`.

5. **Sanity-check:** `bash -n xfstests-bridge/tests/nfs/NNN`

6. **Re-run `install.sh`** to sync the new files into your
   xfstests tree.

7. **Run the wrapper:** `./check -nfs nfs/NNN`

The CI workflow at `.github/workflows/xfstests-bridge.yml` will
verify syntax and framing on every push.

## Submitting upstream

The end state is for these wrappers to live in
`kdave/xfstests/tests/nfs/` upstream.  Submission steps, when
ready:

1. Confirm the cthon26 binaries they wrap are dual-licensed
   `BSD-2-Clause OR GPL-2.0-only` (they are) and that cthon26 is
   in a published, maintained state.
2. Rebase the bridge commits to carry xfstests' preferred
   `Signed-off-by:` and `Co-developed-by:` trailers for any
   multi-party work.
3. Post to the [fstests mailing list](https://lore.kernel.org/fstests/)
   with a cover letter describing cthon26, the test numbering
   choice, and the `common/cthon26` helper.
4. Split the series thoughtfully: one introductory patch for
   `common/cthon26` plus the first few representative wrappers,
   then follow-up patches for the rest in logical groups.

Until that lands, installing via `install.sh` into the tester's
own xfstests clone is the supported path, and this document
stays authoritative for how it works.

## Relationship to TAP mode

xfstests and TAP are independent consumers of the same cthon26
binaries.  A tester can use either (or both) depending on what
their tooling prefers:

| Consumer | Entry point | Best for |
|----------|-------------|----------|
| TAP (`prove`) | `NFSV42_TESTS_TAP=1 prove ...` | Developers, quick iteration |
| TAP (aggregate) | `runtests --tap` | Self-contained CI, no Perl |
| xfstests | `./check -nfs -g nfs` | Filesystem / NFS maintainers |
| cthon04 classic | `./runtests -t` (cthon26 root) | Tradition, multi-OS portability |

See [`docs/tap.md`](tap.md) for the TAP deep-dive.

## See also

- [xfstests upstream](https://github.com/kdave/xfstests)
- [xfstests README](https://github.com/kdave/xfstests/blob/master/README)
- [fstests mailing list archive](https://lore.kernel.org/fstests/)
- [`xfstests-bridge/README.md`](../xfstests-bridge/README.md) —
  bridge-specific quick start
- [`nfsv42-tests/README.md`](../nfsv42-tests/README.md) — per-test
  descriptions and environmental NOTEs
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) — contribution rules
  (including the kernel-style `Assisted-by:` trailer)
