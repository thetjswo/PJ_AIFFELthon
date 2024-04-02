from . import session
from ..table_info import Users

from datetime import datetime


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


def update_user_info(user):
    session.query(Users).filter(Users.uid == user.uid).update({
        'user_name': user.name,
        'user_id': user.email,
        'user_pw': user.password,
        'phone_num': user.phone,
        'address': user.address

    })
    session.commit()


def get_only_user_id(uid) -> int:
    return session.query(Users.id).filter(Users.uid == uid).scalar()
