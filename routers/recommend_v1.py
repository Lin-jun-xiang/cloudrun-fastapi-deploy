from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
import os

PROJECT_ID = os.environ["PROJECT_ID"]

recommend_router = APIRouter(
    prefix="/v1/recommend",
    tags=["recommend algorithm v1"]
    )

class RequestData(BaseModel):
    user_agent: Optional[str] = None
    ip_address: Optional[str] = None
    hanns_account: Optional[str] = None

class Request(BaseModel):
    page: str
    data: RequestData

@recommend_router.post("")
async def get_recommend(Request: Request):
    request_data = Request.data

    ip_address = request_data.ip_address

    return {
            "code": "0",
            "msg": "success",
            "ip_address": ip_address
    }
