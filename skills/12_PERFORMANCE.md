# 12 — Performance

**Purpose:** Preserve measured limits and profiling guidance.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); there are no executable paths or performance measurements.

No request-volume limits, latency targets, hot paths, expensive operations, or profiling tools are documented. Do not guess thresholds or optimize an unmeasured design. When measurements exist, record workload, environment, percentile/limit, profiler command, and the cost of changing deliberate tradeoffs; a number without its measurement context is not actionable.
