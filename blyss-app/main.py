from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def read_root() -> dict[str, str]:
    return {"message": "Hello World!"}


@app.get("/api/health/live")
async def health_live() -> dict[str, str]:
    return {"status": "ok"}
