import unittest

from dora import summarize

SAMPLE = [
    {"createdAt": "2026-01-01T10:00:00Z", "mergedAt": "2026-01-01T10:10:00Z"},
    {"createdAt": "2026-01-01T11:00:00Z", "mergedAt": "2026-01-01T11:20:00Z"},
    {"createdAt": "2026-01-03T09:00:00Z", "mergedAt": "2026-01-03T10:00:00Z"},
]


class DoraTest(unittest.TestCase):
    def test_counts_and_days(self):
        result = summarize(SAMPLE)
        self.assertEqual(result["merged_prs"], 3)
        self.assertEqual(result["active_days"], 2)

    def test_lead_times(self):
        result = summarize(SAMPLE)
        self.assertEqual(result["lead_time_median_min"], 20.0)
        self.assertEqual(result["lead_time_p90_min"], 60.0)
        self.assertEqual(result["lead_time_max_min"], 60.0)

    def test_empty_input(self):
        self.assertIsNone(summarize([]))


if __name__ == "__main__":
    unittest.main()
