# app/main.py
from fastapi import FastAPI
from .api import router as api_router

# Initialize the FastAPI application
app = FastAPI(
    title="Sathi Ally API",
    description="Backend for the Sathi Ally mobile app to de-escalate online hate speech.",
    version="1.0.0"
)

# Include the API router
# This adds all the routes defined in api.py (e.g., /score) to our main app.
app.include_router(api_router, prefix="/api/v1")

@app.get("/", tags=["Root"])
async def read_root():
    """
    A simple root endpoint to confirm the API is running.
    """
    return {"message": "Welcome to the Sathi Ally API!"}