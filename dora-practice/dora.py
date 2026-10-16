import json
import statistics
import sys
from datetime import datetime


def parse(ts):
    return datetime.fromisoformat(ts.replace("Z", "+00:00"))


def summarize(prs):
    if not prs:
        return None
    leads = sorted(
        (parse(p["mergedAt"]) - parse(p["createdAt"])).total_seconds() / 60
        for p in prs
    )
    merged = sorted(parse(p["mergedAt"]) for p in prs)
    span_days = max((merged[-1] - merged[0]).total_seconds() / 86400, 1)
    active_days = len({m.date() for m in merged})
    p90 = leads[min(len(leads) - 1, int(round(0.9 * (len(leads) - 1))))]
    return {
        "merged_prs": len(prs),
        "span_days": round(span_days, 1),
        "active_days": active_days,
        "merges_per_day": round(len(prs) / span_days, 2),
        "lead_time_median_min": round(statistics.median(leads), 1),
        "lead_time_p90_min": round(p90, 1),
        "lead_time_max_min": round(leads[-1], 1),
    }


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: dora.py FILE.json")
    with open(sys.argv[1]) as f:
        prs = json.load(f)
    result = summarize(prs)
    if result is None:
        sys.exit("no PRs in file")
    for key, value in result.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()
