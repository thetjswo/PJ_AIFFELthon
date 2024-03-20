# 도메인 생성 : sqlalchemy CRUD 구현하기

from datetime import datetime
from database import Users, CCTVDevices, CCTVVideos, Settings, EventLogs, ReportLogs, ShareLogs, CheckLogs, PushLogs
import database

from sqlalchemy.orm import sessionmaker
database.Session = sessionmaker(bind=database.engine)   # 데이터베이스와 대화가 필요할 때 session을 불러서 씀
session = database.Session()

# Create
user02 = Users(user_name="user02", user_id="user02@naver.com", user_pw="user02", phone_num="01022222222", address="user02", del_fl=0, rest_fl=0, role_type=1, created_at=datetime.now())
user03 = Users(user_name="user03", user_id="user03@gmail.com", user_pw="user02", phone_num="01033333333", address="user02", del_fl=0, rest_fl=0, role_type=1, created_at=datetime.now())

# session.add("추가할 객체 이름")
# ex) User를 DB에 추가
session.add(user03)
session.commit()


# Update
# session.query(수정할 객체 타입).filter_by("수정할 객체 정보").update("수정 사항")
# ex) 입력한 user_pw가 일치하는 User의 정보를 수정
session.query(Users).filter_by(user_pw="user01").update({"user_pw" : "user0101"})
session.commit()


# Select : 로그인 시 사용자가 입력한 이메일을 우리가 가지고 있는지 확인할 때 사용
# obj = session.query("검색할 객체 타입").filter_by("검색 옵션")
# ex) 입력한 user_id가 일치하는 User 검색

# 쿼리 결과에서 첫 번째 항목만을 반환 : 쿼리 결과가 단일 객체일 때 유용한 방법
tmpUser = session.query(Users).filter_by(user_id="user02@naver.com").first()
print (tmpUser.user_id)

# 쿼리에 해당하는 모든 결과를 리스트 형태로 반환 : 해당 user의 정보를 통째로 가져오기
tmpUser = session.query(Users).filter_by(user_id="user02@naver.com").all()
print (tmpUser)


# Delete -- 사용하지 않기로 결정
# session.query("삭제할 객체 타입").filter_by("삭제할 객체 정보")
# ex) 입력한 user_id가 일치하는 User 삭제
# session.query(Users).filter_by(user_id="user01").delete()
# session.commit()