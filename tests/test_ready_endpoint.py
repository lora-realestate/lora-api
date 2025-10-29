import pytest
from httpx import AsyncClient

@pytest.mark.integration
async def test_ready_endpoint(aclient: AsyncClient):
    response = await aclient.get("/ready")
    assert response.status_code == 200
    assert response.json() == {"ready": True}
