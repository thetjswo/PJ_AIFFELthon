from . import session
from ..table_info import CCTVDevices

class CCTVDeviceDAO:
    def get_by_user_id(id) -> CCTVDevices:
        return session.query(CCTVDevices).filter(user_id=id).first()