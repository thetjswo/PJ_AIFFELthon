from . import session
from ..table_info import Users

from datetime import datetime


class UserDAO:
    def insert_new_user(user) -> bool:
        session.add(user)
        session.commit()

        return True

    # 사용자 정보 조회 쿼리 by uid
    def get_by_uid(uid) -> Users:
        return session.query(Users).filter(Users.uid == uid).first()

    def update_access_time(uid) -> None:
        session.query(Users).filter(Users.uid == uid).update({'last_access_time': datetime.now()})
        session.commit()

        return None