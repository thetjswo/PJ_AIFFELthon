from typing import Optional

from sqlmodel import SQLModel, Field
from datetime import datetime


# 사용자 정보 테이블
class Users(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "users"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # 사용자 이름
    user_name: str = Field(nullable=False)
    # 사용자 ID
    user_id: str = Field(nullable=False)
    # 사용자 PW
    user_pw: str = Field(nullable=False)
    # 사용자 전화번호
    phone_num: Optional[str] = None
    # 사용자 주소
    address: Optional[str] = None
    # 개인정보 수집 동의 여부
    is_agreed: Optional[bool] = False
    # 사용자 UID
    uid: Optional[str] = Field(default=None, primary_key=True)
    # 계정 삭제 여부
    del_fl: bool = Field(default=False, nullable=False)
    # 휴면 계정 여부
    rest_fl: bool = Field(default=False, nullable=False)
    # 사용자 권한(관리자/일반 사용자)
    role_type: int = Field(default=1)
    # 마지막 접속 시간
    last_access_time: Optional[datetime] = None
    # 생성 시간
    created_at: datetime = Field(default=datetime.now, nullable=False)
    # 갱신 시간
    updated_at: Optional[datetime] = None


# 스마트폰 단말기 테이블
class UserDevices(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "user_devices"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # 장치 모델명
    device_name: Optional[str] = None
    # 운영 체제 버전
    os_version: Optional[str] = None
    # 유심칩 슬롯 고유값
    imei: Optional[str] = None
    # 장치 고유 값
    uuid: Optional[str] = Field(default=None, primary_key=True)
    # fcm 토큰 고유 값
    push_id: Optional[str] = None
    # 설치된 앱 버전
    app_version: Optional[str] = None
    # 앱 삭제 여부 확인
    del_fl: bool = Field(default=False, nullable=False)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 생성 시간
    created_at: datetime = Field(default=datetime.now, nullable=False)
    # 갱신 시간
    updated_at: Optional[datetime] = None



# # Users 테이블의 유니크 키와 UserDevices 테이블의 유니크 키를 매핑
# class UserToDevices(SQLModel, table=True):
#     __tablename__ = "user_to_devices"
#     id: int = Field(default=None, primary_key=True)
#     user_uid: str = Field(foreign_key="users.uid")
#     device_uuid: str = Field(foreign_key="user_devices.uuid")


# CCTV 카메라 정보 테이블
class CCTVDevices(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "cctv_devices"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # 장치 이름
    cctv_name: Optional[str] = None
    # 설치 위치
    location: Optional[str] = None
    # 장치 IP
    ip_address: Optional[str] = None
    # 장치 port
    port: Optional[str] = None
    # 장치 연결 상태
    status: str = Field(default='Unconnected', nullable=False)
    # 장치 고유 값
    uuid: Optional[str] = Field(default=None, primary_key=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 생성 시간
    created_at: datetime = Field(default=datetime.now, nullable=False)
    # 갱신 시간
    updated_at: Optional[datetime] = None



# # Users 테이블의 유니크 키와 CCTV Devices 테이블의 유니크 키를 매핑
# class UserToCCTVDevices(SQLModel, table=True):
#     __tablename__ = "user_to_cctv_devices"
#     id: int = Field(default=None, primary_key=True)
#     user_uid: str = Field(foreign_key="users.uid")
#     cctv_uuid: str = Field(foreign_key="cctv_devices.uuid")


# 촬영 영상 정보 테이블
class CCTVVideos(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "cctv_videos"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # 파일 이름
    file_name: str = Field(nullable=False)
    # 파일 저장 경로
    file_path: str = Field(nullable=False)
    # 경보 해제 여부
    is_checked: bool = Field(default=False, nullable=False)
    # 공유 여부
    is_shared: bool = Field(default=False, nullable=False)
    # 신고 여부
    is_reported: bool = Field(default=False, nullable=False)
    # 외래키 - CCTV 카메라 정보 테이블의 ID 값
    cctv_id: int = Field(foreign_key='cctv_devices.id')
    # 생성 시간
    created_at: datetime = Field(default=datetime.now, nullable=False)
    # 갱신 시간
    updated_at: Optional[datetime] = None


# 사용자 설정 정보 테이블
class Settings(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "settings"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # 저장 여부
    record_yn: bool = Field(default=True, nullable=False)
    # 보안모드 여부
    detection_yn: bool = Field(default=True, nullable=False)
    # 위험 판단 시간
    detection_time: int = Field(default=20, nullable=False)
    # 감지 구역
    detection_area: int = Field(default=1, nullable=False)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 생성 시간
    created_at: datetime = Field(default=datetime.now, nullable=False)
    # 갱신 시간
    updated_at: Optional[datetime] = None


# 이벤트 발생 정보 테이블
class EventLogs(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "event_logs"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # 탐지에 사용된 모델 종류
    model: Optional[str] = None
    # 위험 감지 타입
    type: str = Field(default='Normal', nullable=False)
    # 에러 메세지
    err_message: Optional[str] = None
    # 통신 메세지
    message: Optional[str] = None
    # 영상 저장 완료 여부
    is_recorded: bool = Field(default=False, nullable=False)
    # 처리 상태
    status: Optional[int] = None
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 외래키 - CCTV 카메라 정보 테이블의 ID 값
    cctv_id: int = Field(foreign_key='cctv_devices.id')
    # 외래키 - 촬영 영상 정보 테이블의 ID 값
    video_id: int = Field(foreign_key='cctv_videos.id')
    # 생성 시간
    created_at: datetime = Field(default=datetime.now, nullable=False)
    # 갱신 시간
    updated_at: Optional[datetime] = None


# 신고 기록 정보 테이블
class ReportLogs(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "report_logs"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # HTTP 통신 프로토콜 종류
    method: Optional[str] = None
    # 에러 메세지
    err_message: Optional[str] = None
    # 통신 메세지
    message: Optional[str] = None
    # 처리 상태
    status: Optional[int] = None
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id: int = Field(foreign_key='event_logs.id')
    created_at: datetime = Field(default=datetime.now, nullable=False)
    updated_at: Optional[datetime] = None


# 공유 기록 정보 테이블
class ShareLogs(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "share_logs"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # HTTP 통신 프로토콜 종류
    method: Optional[str] = None
    # 에러 메세지
    err_message: Optional[str] = None
    # 통신 메세지
    message: Optional[str] = None
    # 처리 상태
    status: Optional[int] = None
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id: int = Field(foreign_key='event_logs.id')
    created_at: datetime = Field(default=datetime.now, nullable=False)
    updated_at: Optional[datetime] = None


# 경보 해제 기록 정보 테이블
class CheckLogs(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "check_logs"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # HTTP 통신 프로토콜 종류
    method: Optional[str] = None
    # 에러 메세지
    err_message: Optional[str] = None
    # 통신 메세지
    message: Optional[str] = None
    # 처리 상태
    status: Optional[int] = None
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id: int = Field(foreign_key='event_logs.id')
    created_at: datetime = Field(default=datetime.now, nullable=False)
    updated_at: Optional[datetime] = None


# TODO: 푸쉬 메세지 전송 규격에 맞게 구성을 해야 함
class PushLogs(SQLModel, table=True):
    # 테이블 명 지정
    __tablename__ = "push_logs"
    # 로우 데이터 고유 값 -> 데이터가 추가될 때마다 1씩 자동 증가
    id: Optional[int] = Field(default=None, primary_key=True, nullable=True)
    # HTTP 통신 프로토콜 종류
    method: Optional[str] = None
    # 에러 메세지
    err_message: Optional[str] = None
    # 통신 메세지
    message: Optional[str] = None
    # 처리 상태
    status: Optional[int] = None
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id: int = Field(foreign_key='users.id')
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id: int = Field(foreign_key='event_logs.id')
    created_at: datetime = Field(default=datetime.now, nullable=False)
    updated_at: Optional[datetime] = None
