from fastapi import FastAPI
from fastapi.responses import JSONResponse
import uvicorn
import os
from lora_api.version import get_version

app = FastAPI(
    title="Lora API",
    description="Automation API for client follow-up workflows",
    version=get_version(),
)

@app.get("/health", tags=["System"])
def health_check():
    return JSONResponse({"status": "ok", "message": "Lora API is healthy"})

@app.get("/", tags=["System"])
def root():
    return {"message": "que onda"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("lora_api.main:app", host="0.0.0.0", port=port, reload=True)

