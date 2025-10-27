import time
import pytest

@pytest.mark.unit
def test_health_ok(clilent):
    t0 = time.perf_counter()
    r = client.get("/health")
    dt = (time.perf_counter() - t0) * 1000

    assert r.status_code == 200
    assert (
            r.headers.get("content-type", "")
            .startswith("application/json")
    )
    body = r.json()
    assert body["status"] == "ok"
    assert "healthy" in body.get("message", "")
    assert dt < 50, f"health too slow {dt:.1f}ms"
