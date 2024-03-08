import json
import os

from sqlalchemy import create_engine, inspect
from create_table import *

# secrets.json 파일 경로 탐색
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SECRET_FILE = os.path.join(BASE_DIR, 'secrets.json')
# secrets.json 파일 읽기
secrets = json.loads(open(SECRET_FILE).read())
# 'db' 키의 values 값 바인딩
db = secrets['db']

# mysql 접속 url
SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{db.get('user')}:{db.get('password')}@{db.get('host')}:{db.get('port')}/{db.get('database')}?charset=utf8"

# mysql 접속 객체 생성
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# 테이블 클래스 리스트
table_list = [Users, CCTVDevices, CCTVVideos, Settings, EventLogs, ReportLogs, ShareLogs, CheckLogs, PushLogs]

# 테이블을 순차적으로 조회
for table_class in table_list:
    # 테이블 이름 추출
    table_name = table_class.__table__.name
    # 기존에 존재하는 테이블인지 확인
    inspector = inspect(engine)
    # 현재 조회중인 테이블이 존재하지 않는다면,
    if not inspector.has_table(table_name):
        # 해당 테이블 클래스로 테이블 생성
        table_class.metadata.create_all(engine)