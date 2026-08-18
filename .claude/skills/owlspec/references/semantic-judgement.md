# Semantic judgement

Owlspec validates structure. **It will never tell you whether the recorded truth is enough.** That
gap is deliberate: deciding what a project still has to specify requires understanding the project's
domain, and no rule table in a tool can do that. This file is the procedure for the part the tool
hands to you.

## Scope

Apply this to **the records you touched plus the context slice around them** — what
`owlspec context` returned for your focus. Not the whole graph. A sweep of every record produces
padding, not findings.

## Produce, don't evaluate

Do not ask yourself "is this record decisive?" — that question is answerable with "yes" in one token
and costs nothing to skip. Ask the question that demands an artifact:

| Ask | And you must answer it with something concrete |
|---|---|
| What is left to decide? | *Name one decision — or one failure, exception, or boundary case — that a future implementer would still have to settle from this record alone.* If you can name it, that is a gap. If you genuinely cannot, say so and move on. |
| How would we know it broke? | *Quote the verification that would tell you this outcome had failed* — or state that none exists. |
| What collides? | *Name the two record ids that cannot both be satisfied, and the scenario in which they collide.* No scenario, no contradiction. |
| What was rejected? | *State the alternative that was not taken.* If none is recorded and the choice was not obvious, that is the finding. |
| What did I make up? | *List every proposition you asserted this session that has no source.* Each becomes a `fact` with `confidence = "assumed"`, or a question to the user. |

For each outcome specifically, ask: **what realistic situation would prevent the expected observable
state even when every stated condition holds?** That question finds more real gaps than the rest of
the table combined.

## Failure signatures

Cheap patterns to match instead of philosophising. Any of these is worth a second look:

- A record body that restates its own title and adds nothing.
- A `decision` with no rejected alternative, for a choice that was not forced.
- An `outcome` with no `verified_by` edge at all.
- A `verification` whose target would still pass if the outcome silently failed.
- A `fact` marked `known` whose source nobody can name.
- An `evidence` record whose observed revision predates the change you are reviewing.
- A `design` body that explains what the code does. The code already does that; a design points.
- A `constraint` phrased as a goal ("should be fast") rather than as something that can be violated.

## Worked examples

### An external call with no failure story

A design says a request is sent to an external service and the operation is confirmed once the
service accepts. Nothing else is recorded.

Ask the production question: *name one decision the implementer still has to make.* Several, and they
are all consequential — what happens when the service accepts but the confirmation never arrives back;
whether a retry can duplicate the effect; how long the caller waits before giving up.

The finding is not "external calls need a timeout." That is a domain rule, and encoding it anywhere
would be wrong. The finding is that **this record leaves a behaviour the implementer will decide
alone, and the project will inherit whatever they pick.**

> Candidate — `design.<id>` · gap · "Behaviour after the remote accepts but the response is lost is
> unspecified; the implementer will choose between retrying (risking duplicate effect) and failing
> (risking a lost confirmation), and either choice becomes de facto truth."

### An outcome that the design cannot reach

An outcome requires the feature to work while offline. The design makes every operation depend on a
synchronous call succeeding.

Ask: *name the two ids that cannot both be satisfied, and the scenario.* Both ids are nameable and
the scenario is one sentence — the user opens the feature with no network. That is a real
contradiction, and it is one no structural validator can see: both records are perfectly well-formed
and the relation between them is legal.

> Candidate — `outcome.<a>` vs `design.<b>` · contradiction · "Offline use is required, but every
> operation blocks on a synchronous remote call; with no network the outcome cannot hold."

### A decision that is only a noun

`# Use SQLite` with a one-line body.

Length is not the problem. Ask the production question: *what would a future implementer have to
re-decide?* Whether the alternatives were even considered, whether the choice was about operational
simplicity or about a specific query pattern, and therefore **whether a future migration away from it
is a small change or a violation of the reasoning that put it there.** All of that is gone.

> Candidate — `decision.<id>` · unjustified · "No rejected alternative and no criterion recorded, so
> a later change of engine cannot tell whether it contradicts this decision or merely revises it."

Contrast: a three-line decision that names one rejected alternative and the criterion that separated
them is *complete*. **Judge by what has to be re-decided, never by length.**

## The output contract

**The findings go in your reply to the user, before you apply the change.** A protocol applied
silently is indistinguishable from a protocol skipped, so the artifact is the point: if nothing was
written down, nothing was judged.

Emit findings as a list. Each entry is:

```text
<record id, or "absent"> · <gap | contradiction | unjustified | unverifiable | unsourced> · <one concrete consequence>
```

**A candidate with no nameable consequence is not a candidate — drop it.**

## Honest exits

The SKILL states the two rules that matter — an empty list is a legitimate answer, and findings are
candidates until the user accepts them. One thing to add here: **if you cannot resolve something, say
so and leave it open.** Writing a confident record over a gap closes it in appearance only, and the
next reader has no way to tell the difference.
