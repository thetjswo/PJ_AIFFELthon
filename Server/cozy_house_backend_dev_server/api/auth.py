import logging
from json import JSONDecodeError

from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel

from models.user import User
from crud import auth as auth_crud

router = APIRouter()


class SignupRequest(BaseModel):
    name: str
    phone: str
    email: str
    password: str
    agree: bool
    uid: str


class SignupResponse(BaseModel):
    message: str


@router.post("/signup", response_model=SignupResponse)
async def signup_route(request: Request):
    # 요청 데이터 파싱
    try:
        request_data = await request.json()
        signup_request = SignupRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    # 사용자 등록
    user = User(
        name=signup_request.name,
        phone=signup_request.phone,
        email=signup_request.email,
        password=signup_request.password,
        agree=signup_request.agree,
        uid=signup_request.uid,

    )

    # Users 테이블에 사용자 정보 저장
    auth_crud.signup(user)

    # 응답 데이터 생성
    response_data = SignupResponse(message="회원가입이 성공적으로 처리되었습니다.")

    # JSON 형식으로 응답 반환
    return response_data
