import pytest
from fastapi.testclient import TestClient
from httpx import AsyncClient, ASGITransport
from lora_api.main import app

@pytest.fixture(scope="session")
def client():
    with TestClient(app) as c:
        yield c

@pytest.fixture(scope="session")
async def aclient():
    transport = ASGITransport(app=app, raise_app_exceptions=True)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
