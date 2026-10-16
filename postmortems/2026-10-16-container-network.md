# Postmortem: Prometheus could not scrape Alertmanager (lab stack)

Date: 2026-10-16 (times are IST)
Severity: low (personal lab, no users affected)
Status: closed, root cause only partly known

## Summary

While testing a Prometheus, Alertmanager and Grafana stack in Docker Compose inside a GitHub Codespace, Prometheus marked the Alertmanager scrape target as down. All three services were running and healthy from the host. The cause was that containers on the same Docker network could not reach each other. The full stack could not be tested end to end.

## Impact

- The Prometheus to Alertmanager scrape (`up{job="alertmanager"}`) was 0.
- Grafana could not be checked against its Prometheus data source.
- Alert routing and inhibition were still tested successfully by talking to Alertmanager directly from the host.
- No production system and no user was affected.

## Timeline

- 12:14: Offline validation passed for the Prometheus config, the Alertmanager config and the Compose file.
- 12:15: Stack started. Prometheus and Alertmanager answered their ready endpoints (HTTP 200) and Grafana reported its database as ok.
- 12:15: A query for `up` showed `alertmanager 0`.
- 12:16: The Prometheus targets API gave the error `context deadline exceeded` (a timeout, not "connection refused").
- 12:19: From inside the Prometheus container, `wget` reported `bad address 'alertmanager:9093'`. The Alertmanager log looked healthy.
- 12:20: `nslookup` from the Prometheus container timed out against the Docker DNS server, and a direct request to the Alertmanager container IP also timed out.
- 12:20: Decision to stop debugging the network and test routing and inhibition through the port published on the host instead.
- 12:23: Stack removed.

## Root cause

Known: containers attached to the same Compose network could not reach each other. Name lookups to the Docker DNS server (127.0.0.11) timed out, and a direct request to the other container's IP address also timed out. The containers themselves were healthy, and their published ports worked from the host.

Not known: why. The Codespace networking may restrict traffic between containers, which would also explain an earlier problem where kind cluster nodes could not resolve Docker Hub. That link is a suspicion, not something I verified. The Compose file and the Prometheus config passed offline validation, so the configuration is unlikely to be the cause.

## What went well

- All configs were validated offline with pinned tool versions before anything was started.
- I read the exact error Prometheus recorded for the failed target instead of guessing.
- The checks were ordered to separate DNS from the network: name lookup first, then a direct request by IP address.
- I stopped debugging when more time would not have produced a fix, and still tested routing and inhibition through the published host port.
- The limits were written into the learning log instead of being hidden.

## What went poorly

- I assumed container networking would work and built the whole stack before testing that assumption.
- I raised a false alarm about a truncated config file, which was only a display glitch in the terminal.
- A first negative test of the config check gave a permission error instead of the intended config error, so it proved nothing until it was redone.

## Action items

- Before building any multi-container stack on a new machine, run a 30 second smoke test: start two small containers on one network and make one reach the other by name.
- Keep the config checks in CI. They run on a GitHub runner where the check does not depend on the Codespace network.
- To finish the end-to-end test, run the same Compose stack on a machine or CI job with normal container networking and check `up` for every target.
- Keep the known Codespace limit written down in the learning log so it is not rediscovered.
