from sqlalchemy import func

from . import session
from ..table_info import EventLogs, Users, CCTVDevices


def get_by_user_id(user_id, date) -> EventLogs:
    return session.query(EventLogs, CCTVDevices.cctv_name) \
        .join(CCTVDevices, EventLogs.cctv_id == CCTVDevices.id) \
        .join(Users, CCTVDevices.user_id == Users.id) \
        .filter(Users.id == user_id) \
        .filter(func.date(EventLogs.created_at) == date) \
        .all()
