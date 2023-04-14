from fastapi import FastAPI
import uvicorn
from routers import recommend_router

app = FastAPI()

app.include_router(recommend_router)

@app.get("/")
def index():
    return "Hello world!"

if __name__ == "__main__":
    uvicorn.run(app="main:app", host="0.0.0.0", port=8000, reload=True)
