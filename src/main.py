from fastapi import FastAPI
from fastapi.responses import JSONResponse
import uvicorn
import os
from version import get_version

app = FastAPI(
    title="Lora API",
    description="Automation API for client follow-up workflows",
    version=get_version(),
)

@app.get("/health", tags=["System"])
def health_check():
    """Simple healthcheck for Docker health probes."""
    return JSONResponse({"status": "ok", "message": "Lora API is healthy"})

@app.get("/", tags=["System"])
def root():
    """Root endpoint (optional)"""
    return {"message": "que onda"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)

