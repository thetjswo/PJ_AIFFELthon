from sqlalchemy import Column, ForeignKey, Integer, String, DateTime, Boolean
from sqlalchemy.orm import declarative_base
from datetime import datetime

Base = declarative_base()


class Users(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 사용자 이름
    user_name = Column(String(length=255), nullable=False)
    # 사용자 ID
    user_id = Column(String(length=255), nullable=False)
    # 사용자 PW
    user_pw = Column(String(length=255), nullable=False)
    # 사용자 전화번호
    phone_num = Column(String(length=255), nullable=True)
    # 사용자 주소
    address = Column(String(length=255), nullable=True)
    # 개인정보 수집 동의 여부
    is_agreed = Column(Boolean, default=False)
    # 사용자 UID
    uid = Column(String(length=255), nullable=True)
    # 계정 삭제 여부
    del_fl = Column(Boolean, default=False, nullable=False)
    # 휴면 계정 여부
    rest_fl = Column(Boolean, default=False, nullable=False)
    # 사용자 권한(관리자/일반 사용자)
    role_type = Column(Integer, default=1)
    # 마지막 접속 시간
    last_access_time = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class UserDevices(Base):
    __tablename__ = "user_devices"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 제조사
    manufacturer = Column(String(length=255), nullable=True)
    # 장치 명
    device_name = Column(String(length=255), nullable=True)
    # 장치 모델명
    device_model = Column(String(length=255), nullable=True)
    # 운영 체제 버전
    os_version = Column(String(length=255), nullable=True)
    # 장치 고유 값
    uuid = Column(String(length=255), nullable=True)
    # fcm 토큰 고유 값
    push_id = Column(String(length=255), nullable=True)
    # 설치된 앱 버전
    app_version = Column(String(length=255), nullable=True)
    # 앱 삭제 여부 확인
    del_fl = Column(Boolean, default=False, nullable=False)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class CCTVDevices(Base):
    __tablename__ = "cctv_devices"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 장치 이름
    cctv_name = Column(String(length=255), nullable=True)
    # 설치 위치
    location = Column(String(length=255), nullable=True)
    # 장치 IP
    ip_address = Column(String(length=255), nullable=True)
    # 장치 port
    port = Column(String(length=255), nullable=True)
    # 장치 연결 상태
    status = Column(String(length=255), default="Unconnected", nullable=False)
    # 장치 고유 값
    uuid = Column(String(length=255), nullable=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class CCTVVideos(Base):
    __tablename__ = "cctv_videos"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 파일 이름
    file_name = Column(String(length=255), nullable=False)
    # 파일 저장 경로
    file_path = Column(String(length=255), nullable=False)
    # 경보 해제 여부
    is_checked = Column(Boolean, default=False, nullable=False)
    # 공유 여부
    is_shared = Column(Boolean, default=False, nullable=False)
    # 신고 여부
    is_reported = Column(Boolean, default=False, nullable=False)
    # 외래키 - CCTV 카메라 정보 테이블의 ID 값
    cctv_id = Column(Integer, ForeignKey("cctv_devices.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class Settings(Base):
    __tablename__ = "settings"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 저장 여부
    record_yn = Column(Boolean, default=True, nullable=False)
    # 보안모드 여부
    detection_yn = Column(Boolean, default=True, nullable=False)
    # 위험 판단 시간
    detection_time = Column(Integer, default=20, nullable=False)
    # 감지 구역
    detection_area = Column(Integer, default=1, nullable=False)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class EventLogs(Base):
    __tablename__ = "event_logs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 탐지에 사용된 모델 종류
    model = Column(String(length=255), nullable=True)
    # 위험 감지 타입
    type = Column(String(length=255), default="Normal", nullable=False)
    # 에러 메세지
    err_message = Column(String(length=255), nullable=True)
    # 통신 메세지
    message = Column(String(length=255), nullable=True)
    # 영상 저장 완료 여부
    is_recorded = Column(Boolean, default=False, nullable=False)
    # 처리 상태
    status = Column(Integer, nullable=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    # 외래키 - CCTV 카메라 정보 테이블의 ID 값
    cctv_id = Column(Integer, ForeignKey("cctv_devices.id"))
    # 외래키 - 촬영 영상 정보 테이블의 ID 값
    video_id = Column(Integer, ForeignKey("cctv_videos.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class ReportLogs(Base):
    __tablename__ = "report_logs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # HTTP 통신 프로토콜 종류
    method = Column(String(length=255), nullable=True)
    # 에러 메세지
    err_message = Column(String(length=255), nullable=True)
    # 통신 메세지
    message = Column(String(length=255), nullable=True)
    # 처리 상태
    status = Column(Integer, nullable=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id = Column(Integer, ForeignKey("event_logs.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class ShareLogs(Base):
    __tablename__ = "share_logs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # HTTP 통신 프로토콜 종류
    method = Column(String(length=255), nullable=True)
    # 에러 메세지
    err_message = Column(String(length=255), nullable=True)
    # 통신 메세지
    message = Column(String(length=255), nullable=True)
    # 처리 상태
    status = Column(Integer, nullable=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id = Column(Integer, ForeignKey("event_logs.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class CheckLogs(Base):
    __tablename__ = "check_logs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # HTTP 통신 프로토콜 종류
    method = Column(String(length=255), nullable=True)
    # 에러 메세지
    err_message = Column(String(length=255), nullable=True)
    # 통신 메세지
    message = Column(String(length=255), nullable=True)
    # 처리 상태
    status = Column(Integer, nullable=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id = Column(Integer, ForeignKey("event_logs.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)


class PushLogs(Base):
    __tablename__ = "push_logs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    # HTTP 통신 프로토콜 종류
    method = Column(String(length=255), nullable=True)
    # 에러 메세지
    err_message = Column(String(length=255), nullable=True)
    # 통신 메세지
    message = Column(String(length=255), nullable=True)
    # 처리 상태
    status = Column(Integer, nullable=True)
    # 외래키 - 사용자 정보 테이블의 ID 값
    user_id = Column(Integer, ForeignKey("users.id"))
    # 외래키 - 이벤트 발생 정보 테이블의 ID 값
    event_id = Column(Integer, ForeignKey("event_logs.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, onupdate=datetime.now)
