from . import session
from ..table_info import UserDevices


def insert_new_device(device) -> bool:
    session.add(device)
    session.commit()

    return True


# 단말기 정보 조회 쿼리 by user_id
# TODO: 복수 개의 단말기를 가지고 있는 케이스 고려
def get_by_user_id(user_id) -> UserDevices:
    return session.query(UserDevices).filter(UserDevices.user_id == user_id).first()

def get_push_id(user_id):
    return session.query(UserDevices.push_id).filter(UserDevices.user_id == user_id).scalar()