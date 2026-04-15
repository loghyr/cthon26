<!--
SPDX-FileCopyrightText: 2026 Tom Haynes <loghyr@gmail.com>
SPDX-License-Identifier: BSD-2-Clause OR GPL-2.0-only
-->

# Running cthon26 with TAP13 output

cthon26 emits [Test Anything Protocol](https://testanything.org/) version
13 output natively, so the suite plugs into every test runner that
speaks TAP — `prove` (Perl), `tappy` (Python), `go-tap`, the TAP
consumers built into Jenkins, GitLab CI, Buildkite, and CircleCI, and
any `_junit` / `_subunit` converter you already have.

This document is the deep-dive reference.  For quick examples see
[`nfsv42-tests/README.md`](../nfsv42-tests/README.md) ("TAP13 output"
section) and the top-level [`README.md`](../README.md) "Quick start"
section.

## What TAP is, in one paragraph

TAP is a line-oriented text protocol for reporting test results.
Each test binary emits a stream of `ok N - description` (pass) and
`not ok N - description` (fail) lines, plus a `1..N` plan that
announces how many tests will run.  Lines starting with `#` are
diagnostic comments that parsers ignore but humans see.  A
`Bail out! reason` line aborts the stream immediately.  That's the
entire grammar.  TAP13 adds the `TAP version 13` header, optional
indented-YAML diagnostic blocks, and nested subtests.  cthon26 uses
the flat TAP13 shape without nesting.

## The three entry points

### 1. One test binary at a time

```
NFSV42_TESTS_TAP=1 ./nfsv42-tests/op_commit -d /mnt/nfs42
```

The `NFSV42_TESTS_TAP` environment variable flips every `nfsv42-tests`
binary from the historical `TEST:/PASS:/FAIL:/SKIP:` output to TAP13.
The binary emits:

```
TAP version 13
# TEST: op_commit: fsync/fdatasync -> NFSv4 COMMIT (RFC 7530 S18.3)
ok 1 - case_fsync_roundtrip
ok 2 - case_fdatasync_roundtrip
ok 3 - case_log_style
ok 4 - case_fsync_ronly_fd
ok 5 - case_fsync_empty
1..5
```

One test binary is one TAP stream, with one `ok`/`not ok` per
`case_foo()` function inside that binary.  The plan line (`1..N`) is
delayed until `finish()` runs so binaries don't need to know their
case count up front.

Tests that do not follow the `case_foo()` pattern (`op_seek`,
`op_io_advise`, `op_statx_btime` have inline `main()` bodies) fall
back to a one-binary-is-one-test mapping: `1..1` plus a single
`ok`/`not ok` line.

### 2. The whole `nfsv42-tests` suite, sequentially

```
./nfsv42-tests/runtests --tap -d /mnt/nfs42
```

or equivalently:

```
make -C nfsv42-tests check-tap CHECK_DIR=/mnt/nfs42
```

`runtests --tap` emits a meta-TAP stream: one `1..N` plan across all
the selected test binaries, one `ok`/`not ok`/`# SKIP` per binary,
and the binary's stdout captured and re-emitted as `#`-prefixed
diagnostic lines so the overall stream remains valid TAP.

Sample:

```
TAP version 13
1..27
# nfsv42-tests under /mnt/nfs42
ok 1 - op_allocate
# TEST: op_allocate: posix_fallocate -> NFSv4.2 ALLOCATE (RFC 7862 S4)
# PASS: op_allocate
ok 2 - op_io_advise
...
not ok 14 - op_setattr
# TEST: op_setattr: chmod/chown/truncate/utimensat -> NFSv4 SETATTR (RFC 7530 S18.30)
# FAIL: case5: chown(1066,10) no-op: Invalid argument
# summary: 26 passed, 1 failed, 0 skipped, 0 missing, 0 bugs
```

This mode is self-contained — no external TAP harness required.  The
exit code is still the automake TESTS `0/1/77/99` convention so shell
scripts that `$? -eq 0` checks continue to work.

### 3. Parallel via `prove`

```
NFSV42_TESTS_TAP=1 prove -j $(nproc) -e '' ./nfsv42-tests/op_*
```

or equivalently:

```
make -C nfsv42-tests check-prove JOBS=$(nproc)
```

`prove` invokes each test binary in parallel (one per job slot),
consumes each binary's own `1..N` TAP stream, aggregates results, and
prints a human-friendly summary at the end:

```
./op_access ............. ok
./op_allocate ........... ok
./op_change_attr ........ ok
./op_clone .............. ok
./op_commit ............. ok
...
All tests successful.

Test Summary Report
-------------------
Files=27, Tests=123, 4.2 wallclock secs ...
Result: PASS
```

The `-e ''` flag tells `prove` to execute the binaries directly
(not to interpret them as Perl scripts).

**Caveat**: tests that create scratch files in the same `-d`
directory can collide when run in parallel.  Use a separate `-d`
per binary, or serialise by using `--tap` on `runtests` instead.

### 4. The cthon04 side

```
./cthon04-tap -d /mnt/nfs42
```

This wraps each of the cthon04 test groups (`basic/`, `general/`,
`special/`, `lock/`) and emits one TAP result per group.  The
group's full output is captured and re-emitted as `#`-prefixed
diagnostics.  Groups run sequentially (cthon04 tests within a
group have ordering dependencies).  Group-level granularity is
intentional — the cthon04 tests do not expose per-test machine-
readable names, so drilling into individual cthon04 tests via TAP
would require invasive changes to 35-year-old code.

## Integrating with CI systems

### GitHub Actions

TAP feeds naturally into GitHub Actions logs.  Run with `runtests
--tap` and pipe to `prove` if you want a JUnit artifact.

```yaml
- name: Run cthon26 NFSv4.x tests
  run: |
    ./nfsv42-tests/runtests --tap -d /mnt/nfs42 > tap.txt
    cat tap.txt
- name: Convert TAP to JUnit XML
  run: prove -j 4 --formatter TAP::Formatter::JUnit ./nfsv42-tests/op_* > results.xml
- name: Upload artifacts
  uses: actions/upload-artifact@v4
  with:
    name: cthon26-results
    path: |
      tap.txt
      results.xml
```

GitHub's "Publish Test Results" actions can ingest the JUnit XML
directly and show pass/fail summaries in the PR UI.

### GitLab CI

GitLab speaks JUnit.  Same conversion pipe:

```yaml
cthon26:
  script:
    - prove -j 4 --formatter TAP::Formatter::JUnit ./nfsv42-tests/op_* > junit.xml
  artifacts:
    reports:
      junit: junit.xml
```

### Jenkins

Jenkins' [TAP Plugin](https://plugins.jenkins.io/tap/) consumes the
TAP stream directly, no conversion step needed:

```groovy
sh './nfsv42-tests/runtests --tap -d /mnt/nfs42 > tap.txt'
step([$class: 'TapPublisher', testResults: 'tap.txt'])
```

### Plain `prove` locally

`prove` has useful flags for iterative debugging:

| Flag | Effect |
|------|--------|
| `-v` | Verbose: show every `ok`/`not ok` line as tests run |
| `--timer` | Show per-test wall time |
| `--failures` | Only show failed tests in the summary |
| `--state=failed,save` | Re-run only the last failing tests |
| `-j N` | Run up to N binaries in parallel |
| `--shuffle` | Random order (catches ordering dependencies) |
| `--norc` | Ignore `~/.proverc` |

Example for debugging a flaky test in isolation:

```
NFSV42_TESTS_TAP=1 prove --timer -v ./nfsv42-tests/op_setattr
```

## Interpreting the output

### Lines you will see

| Line | Meaning |
|------|---------|
| `TAP version 13` | Protocol declaration, exactly once at the top |
| `1..N` | Plan: N tests will run (or ran, if at the end) |
| `# ...` | Diagnostic comment — ignored by parsers, visible to humans |
| `ok N - name` | Test N passed |
| `not ok N - name` | Test N failed |
| `ok N - name # SKIP reason` | Test N was skipped (no unmet expectation) |
| `1..0 # SKIP reason` | The entire binary was skipped before any case ran |
| `Bail out! reason` | Fatal: abort the whole run |

### Skip vs. fail vs. bail

- **Skip** means the test could not be run because of environment
  (kernel too old, feature unsupported, missing tool).  Skipped
  tests do not count as failures.
- **Fail** means the test ran and produced a wrong answer.  This
  is an actionable defect in the server, client, or test code.
- **Bail** means the test encountered a condition so broken that
  running further tests would be pointless (e.g., scratch mount
  is read-only).  Bail is rare; it stops the stream immediately.

### Case-level vs. binary-level

When a binary uses `RUN_CASE("case_foo", case_foo())` internally
(all `nfsv42-tests` tests except the three with inline `main`
bodies), the TAP stream has one line per case:

```
ok 1 - case_fstat_stat_agree
ok 2 - case_incremental_size
not ok 3 - case_fork_child_stat
```

`prove` treats these as subtests of the binary:

```
./op_deleg_attr ........ 1/7 subtests passed
```

When a binary does not use `RUN_CASE`, the whole binary is one TAP
test and its pass/fail is derived from its exit code (0 = `ok`,
77 = `ok # SKIP`, other = `not ok`).

## Troubleshooting

### "I see no TAP output"

Check the env var: `NFSV42_TESTS_TAP=1` (the script looks for a
non-empty, non-`"0"` value).  Values like `NFSV42_TESTS_TAP=yes`
also work.

### "prove says ERROR: file not found"

Pass `-e ''` so `prove` treats the binaries as executables, not Perl
scripts.  Alternatively add `#!/usr/bin/env prove` style shebangs —
but since our binaries are C, `-e ''` is the right idiom.

### "My CI shows `# summary:` as a test"

That's a diagnostic line, not a test result.  If your CI parser
treats it as a test, check that it groks TAP13 (the diagnostic
lines inside a binary's subtest block) — most modern parsers do.
For older parsers, convert to JUnit first.

### "Tests pass in sequence but fail under `prove -j N`"

Tests share scratch filenames in the current directory.  Either
give each test its own `-d` mount, or run without `-j` (sequential).

### "I want per-case granularity in `runtests --tap`"

The `runtests` aggregate mode is one line per binary by design —
it's what makes the stream self-contained.  For per-case
granularity, use `prove` directly with `NFSV42_TESTS_TAP=1`.

## TAP spec pointers

- [TAP13 spec](https://testanything.org/tap-version-13-specification.html)
- [`prove(1)` manual](https://perldoc.perl.org/prove)
- [`Test::Harness` Perl module](https://metacpan.org/pod/Test::Harness)
- [TAP::Parser](https://metacpan.org/pod/TAP::Parser) if you're
  writing a custom TAP consumer

## See also

- [`docs/xfstests.md`](xfstests.md) — running the same tests through
  the xfstests harness instead of bare TAP
- [`nfsv42-tests/README.md`](../nfsv42-tests/README.md) — per-test
  descriptions and environmental NOTEs
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) — how to add new tests
  and the kernel-style `Assisted-by:` trailer convention
