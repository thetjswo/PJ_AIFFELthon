import logging
from json import JSONDecodeError

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
    date: str
    file_name: str
    is_checked: bool
    created_at: str
    cctv_name: str
    type: str     # TODO: type값 DB에서 가져오는 걸로 수정하기


# 선택한 날짜 영상 엔드포인트
@router.post("/selected_date", response_model=SelectedDateResponse)
async def history_route(request: Request):
    try:
        request_data = await request.json()
        date_request = SelectedDateRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    data = history.selected_date(date_request)

    # 날짜 선택 여부를 확인
    # if문 : 날짜를 선택했는지 판단
    if data['result']:
        response_data = SelectedDateResponse(
            uid=data['uid'],
            created_at=data['created_at'],
        )

        return response_data  # 인증 성공 시 사용자 정보(response_data)를 사용하여 SelectDateResponse 객체를 생성

    # 실패 시 빈 문자열을 가진 SelectDateResponse 객체를 생성하여 반환
    else:
        response_data = SelectedDateResponse(
            uid='',
            created_at='',
        )

        return response_data