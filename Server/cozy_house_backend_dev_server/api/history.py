import logging
from datetime import datetime
from json import JSONDecodeError
from typing import Dict, Any

from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel

from crud import history

router = APIRouter()


# 선택한 날짜의 영상 목록 요청
class SelectedDateRequest(BaseModel):
    uid: str
    date: str


# 선택한 날짜의 영상 목록 응답
class SelectedDateResponse(BaseModel):
    response_data: Dict[str, Any]


# 선택한 날짜 영상 엔드포인트
@router.post("/selected_date", response_model=SelectedDateResponse)
async def history_route(request: Request):
    try:
        request_data = await request.json()
        date_request = SelectedDateRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    # {카메라 이름: {id: 1, model: object-detection ...}}의 형태
    data = history.selected_date(date_request)

    response_data = SelectedDateResponse(
        response_data=data
    )

    return response_data