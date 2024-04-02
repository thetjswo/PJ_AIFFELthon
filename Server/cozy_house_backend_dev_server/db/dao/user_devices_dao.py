from . import session
from ..table_info import CCTVDevices, Users, CCTVVideos, UserDevices


class UserDeviceDAO:
    def insert_new_device(device) -> bool:
        session.add(device)
        session.commit()

        return True

    # 단말기 정보 조회 쿼리 by user_id
    # TODO: 복수 개의 단말기를 가지고 있는 케이스 고려
    def get_by_user_id(id) -> UserDevices:
        return session.query(UserDevices).filter(user_id = id).first()
    
    def get_by_cctv_id(id, selected_date) -> None:
        return session.query(CCTVVideos).filter_by(cctv_id=id, created_at=selected_date).all()