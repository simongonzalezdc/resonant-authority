# Resonant Authority

A self-contained POSIX add-on that implements **contextual authority** — the idea at the
heart of the [ResonantDAO whitepaper](https://resonantdao.com/whitepaper): a question
declares its salient dimensions, and weight comes from **verified outcomes in exactly
those dimensions** — never a blanket score, never capital, never activity.

This is a **non-canonical** worked implementation: it exists to make the whitepaper's
core idea runnable and testable today. The custodian's future specification supersedes it.

## What it does

- `question --dimensions planning,shell` — ranks lanes by weighted accepted-count of
  verified outcomes; rejections are reported separately (evidence, never a subtraction);
  the human class is shown separately and never blended; "no verified outcomes" is a
  first-class answer, never a forced winner.
- `record --date --dimension --lane --verdict accepted|rejected --source PATH` — appends
  a verified outcome whose source must verbatim contain that verdict.

Every event's source pointer must resolve; unresolved sources are reported and excluded,
never silently dropped. Nothing in the ledger is ever interpolated into a shell string —
all parsing treats stored content as data (two independent adversarial security reviews).

## Delegation contract

Consumes `TASK.md` from a delegation dir, writes `artifact.md`:

```
dimensions: planning,process
record: 2026-08-30|planning|my-lane|accepted|./DEMO_SOURCE.md
```

Exit code 0 only if the task is well-formed and every directive succeeded. A 13-event
demo ledger and its verbatim source ship in `authority-ledger/` + `DEMO_SOURCE.md`.

## Install (sideload)

Validate `manifest.json` against the current add-on validator and sideload per the
ResonantOS add-on docs. Extends: add dimensions to `authority-ledger/dimensions.txt`,
human lanes to `authority-ledger/human-lanes.txt` (one name per line).

## License

MIT. The contextual-authority concept is the ResonantDAO whitepaper's; this implementation
is mine and offered to the Builders' Guild in the spirit of the manifesto.
