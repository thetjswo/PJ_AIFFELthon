"""
Users 클래스와 같은 DB 테이블 정보를 담고 있는 클래스들은 최초 1회만 사용하기 때문에
__init__.py에서 별도로 객체를 생성하지 않아도 된다.
"""
from db.database import DBConnector

db_connector = DBConnector()