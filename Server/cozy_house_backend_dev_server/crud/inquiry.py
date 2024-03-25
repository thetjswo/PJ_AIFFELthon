from sqlalchemy.orm import sessionmaker

from db import db_connector
from db.table_info import Users, UserDevices

Session = sessionmaker(bind=db_connector.engine)
session = Session()

class UserDAO:
    # 사용자 정보 조회 쿼리 by uid
    def get_by_uid(uid) -> Users:
        return session.query(Users).filter(Users.uid == uid).first()


class UserDeviceDAO:
    # 단말기 정보 조회 쿼리 by user_id
    def get_by_user_id(user_id) -> UserDevices:
        return session.query(UserDevices).filter(UserDevices.user_id == user_id).first()
