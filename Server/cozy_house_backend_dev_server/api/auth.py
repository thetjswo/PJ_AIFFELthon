import logging
from json import JSONDecodeError

from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel

from crud import auth

router = APIRouter()


# 요청 : 플러터에서 -> 서버로 요청하는 내용
# 회원가입 요청
class SignupRequest(BaseModel):
    name: str
    phone: str
    email: str
    password: str
    agree: bool
    uid: str


# 장치 정보 요청
class DeviceInfoRequest(BaseModel):
    user_uid: str
    manufacturer: str
    device_name: str
    device_model: str
    os_version: str
    uuid: str
    push_id: str
    app_version: str


# 로그인 요청
class SigninRequest(BaseModel):
    uid: str


# 선택한 날짜의 영상 목록 요청 
class SelectDateRequest(BaseModel):
    uid: str
    date: str


# 사용자 정보 요청
class UserInfoRequest(BaseModel):
    uid: str
    name: str
    phone: str
    email: str
    password: str
    address: str


# 응답 : 서버에서 -> 플러터로 요청받은 내용을 전달
# 회원가입 응답
class SignupResponse(BaseModel):
    message: str


# 장치 정보 응답
class DeviceInfoResponse(BaseModel):
    message: str


# 로그인 응답
class SigninResponse(BaseModel):
    user_name: str
    user_id: str
    user_pw: str
    phone_num: str
    address: str
    device_uuid: str


# 선택한 날짜의 영상 목록 응답
class SelectDateResponse(BaseModel):
    date: str
    file_name: str
    is_checked: bool
    created_at: str
    cctv_name: str
    type: str     # TODO: type값 DB에서 가져오는 걸로 수정하기


# 사용자 정보 응답
class UserInfoResponse(BaseModel):
    message: str


# FastAPI 프레임워크를 사용하여 회원가입 엔드포인트를 구현
@router.post("/signup", response_model=SignupResponse)   # HTTP POST 메서드를 사용하는 "/signup" 엔드포인트를 정의하며, 이 엔드포인트는 SignupResponse 모델을 반환
async def signup_route(request: Request):       # "signup_route" 함수는 요청을 처리하고 응답을 반환하는 역할을 하며, FastAPI에서 사용되는 Request 객체를 매개변수로 받는다.
    # 요청 데이터 파싱
    try:  # 예외처리
        request_data = await request.json()
        signup_request = SignupRequest(**request_data)    # SignupRequest 클래스를 사용하여 요청 데이터를 객체로 변환. request_data에 있는 데이터를 SignupRequest 객체의 속성으로 설정.
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    # Users 테이블에 사용자 정보 저장
    auth.signup(signup_request)   # auth 모듈에서 signup 함수를 호출하여 signup_request를 인수로 전달

    # 응답 데이터 생성
    response_data = SignupResponse(message="회원가입이 성공적으로 처리되었습니다.")

    # JSON 형식으로 응답 반환
    return response_data


# 기기정보 엔드포인트 구현
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


# 로그인 엔드포인트 구현
@router.post("/signin", response_model=SigninResponse)
async def signin_route(request: Request):
    try:
        request_data = await request.json()
        signin_request = SigninRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    data = auth.signin(signin_request)

    # 사용자 인증 결과를 확인
    # if문 : data 딕셔너리에서 'result' 키의 값을 확인하여 사용자 인증이 성공했는지 여부를 판단
    if data['result']:
        response_data = SigninResponse(
            user_name=data['user_name'],
            user_id=data['user_id'],
            user_pw=data['user_pw'],
            phone_num=data['phone_num'],
            address=data['address'],
            uid=data['uid'],
            device_uuid=data['device_uuid'],
        )

        return response_data    # 인증 성공 시 사용자 정보(response_data)를 사용하여 SigninResponse 객체를 생성
    
    # 인증 실패 시 빈 문자열을 가진 SigninResponse 객체를 생성하여 반환
    else:
        response_data = SigninResponse(
            user_name='',
            user_id='',
            user_pw='',
            phone_num='',
            address='',
            uid='',
            device_uuid='',
        )

        return response_data


# 선택한 날짜 영상 엔드포인트
@router.post("/tester", response_model=SelectDateResponse)
async def tester_route(request: Request):
    try:
        request_data = await request.json()
        date_request = SelectDateRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    data = auth.select_date(date_request)

    # 날짜 선택 여부를 확인
    # if문 : 날짜를 선택했는지 판단
    if data['result']:
        response_data = SelectDateResponse(
            uid=data['uid'],
            created_at=data['created_at'],
        )

        return response_data    # 인증 성공 시 사용자 정보(response_data)를 사용하여 SelectDateResponse 객체를 생성
    
    # 실패 시 빈 문자열을 가진 SelectDateResponse 객체를 생성하여 반환
    else:
        response_data = SelectDateResponse(
            uid='',
            created_at='',
        )

        return response_data

# 사용자 정보 갱신 엔드포인트
@router.post("/update/userinfo", response_model=UserInfoResponse)
async def signin_route(request: Request):
    try:
        request_data = await request.json()
        userinfo_request = UserInfoRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    auth.user_info(userinfo_request)

    response_data = UserInfoResponse(message="사용자 정보 갱신을 완료했습니다.")

    return response_data