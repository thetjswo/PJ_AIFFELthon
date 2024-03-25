import logging
from json import JSONDecodeError

from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel
from crud import auth

router = APIRouter()


class SignupRequest(BaseModel):
    name: str
    phone: str
    email: str
    password: str
    agree: bool
    uid: str


class DeviceInfoRequest(BaseModel):
    user_uid: str
    manufacturer: str
    device_name: str
    device_model: str
    os_version: str
    uuid: str
    push_id: str
    app_version: str


class SignupResponse(BaseModel):
    message: str


class DeviceInfoResponse(BaseModel):
    message: str


@router.post("/signup", response_model=SignupResponse)
async def signup_route(request: Request):
    # 요청 데이터 파싱
    try:
        request_data = await request.json()
        signup_request = SignupRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    # Users 테이블에 사용자 정보 저장
    auth.signup(signup_request)

    # 응답 데이터 생성
    response_data = SignupResponse(message="회원가입이 성공적으로 처리되었습니다.")

    # JSON 형식으로 응답 반환
    return response_data


@router.post("/deviceinfo", response_model=DeviceInfoResponse)
async def get_device_info_route(request: Request):
    try:
        request_data = await request.json()
        deviceinfo_request = DeviceInfoRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    auth.device_info(deviceinfo_request)

    response_data = DeviceInfoResponse(message="기기 정보 갱신을 완료 했습니다.")

    return response_data