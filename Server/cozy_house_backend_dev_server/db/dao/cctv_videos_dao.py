from sqlalchemy import func

from . import session
from ..table_info import CCTVVideos, CCTVDevices, Users


def get_by_user_id(user_id, selected_date) -> None:
    return session.query(CCTVVideos).join(CCTVDevices, CCTVVideos.cctv_id == CCTVDevices.id).join(Users, Users.id == CCTVDevices.user_id).filter(Users.id == user_id).filter(func.date(CCTVVideos.created_at) == selected_date).all()


def get_thumbnail_path_by_id(video_id):
    return session.query(CCTVVideos).filter(CCTVVideos.id == video_id).first()