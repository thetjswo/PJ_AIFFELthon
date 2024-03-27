from . import session
from ..table_info import UserDevices


class UserDeviceDAO:
    def insert_new_device(device) -> bool:
        session.add(device)
        session.commit()

        return True

    # 단말기 정보 조회 쿼리 by user_id
    # TODO: 복수 개의 단말기를 가지고 있는 케이스 고려
    def get_by_user_id(id) -> UserDevices:
        return session.query(UserDevices).filter(UserDevices.user_id == id).first()