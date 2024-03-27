# 앱의 History 페이지 : cctv_videos 테이블 CRUD 구현하기
# cctv_videos 데이터테이블에 임의의 데이터를 넣고, Users 테이블에서 해당 영상 정보 조회하기

from datetime import datetime
from database import Users, CCTVDevices, CCTVVideos, Settings, EventLogs, ReportLogs, ShareLogs, CheckLogs, PushLogs
import database

from sqlalchemy.orm import sessionmaker
database.Session = sessionmaker(bind=database.engine)   # 데이터베이스와 대화가 필요할 때 session을 불러서 씀
session = database.Session()

# Create : 임의의 데이터 생성
video01 = CCTVVideos(file_name="video01", file_path="Server/cozy_house_backend_test_server/db/IMG_4969.MOV", is_checked=0, is_shared=0, is_reported=0, cctv_id=1, created_at=datetime.now())
session.add(video01)
session.commit()

# 데이터 생성할 때 에러 발생 시 원인 확인을 위해
# try:
#     session.add(video01)
#     session.commit()
# except Exception as e:
#     print("에러 발생:", e)
#     session.rollback()   # 에러 발생 시 롤백하여 변경사항 취소


# Users 테이블(사용자 정보 조회 쿼리)에서 cctv_videos 조회하기
tmpUser = session.query(Users).filter_by(user_id="user01").first()
tmpCCTV = session.query(CCTVDevices).filter_by(user_id=tmpUser.id).first()   # cctv_devices 테이블에서 Users 테이블의 user_id로 해당 사용자의 기기 정보를 연결
tmpVideo = session.query(CCTVVideos).filter_by(cctv_id=tmpCCTV.id).first()   # cctv_videos 테이블에서 cctv_devices 테이블의 cctv_id로 해당 기기의 영상 정보를 연결
print(tmpVideo)   # 해당 사용자의 영상 정보 불러오기
print(tmpCCTV.cctv_name)   # 해당 사용자의 카메라 이름 정보 불러오기