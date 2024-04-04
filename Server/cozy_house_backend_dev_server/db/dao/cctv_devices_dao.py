from . import session
from ..table_info import CCTVDevices


def get_by_user_id(user_id) -> CCTVDevices:
    return session.query(CCTVDevices).filter(user_id=user_id).first()