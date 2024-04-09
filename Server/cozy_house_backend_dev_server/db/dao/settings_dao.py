from datetime import datetime

from . import session
from ..table_info import Users, Settings


def get_user_settings_info(user_id):
    settings = session.query(Settings).filter(Settings.user_id == user_id).first()

    if settings is not None:
        return settings
    else:
        set_settings = Settings(
            record_yn=True,
            detection_yn=True,
            detection_time=20,
            detection_area=0,
            user_id=user_id,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )

        session.add(set_settings)
        session.commit()

        return session.query(Settings).filter(Settings.user_id == user_id).first()


def update_detection_yn(user_id):
    settings = session.query(Settings).filter(Settings.user_id == user_id).first()

    if settings.detection_yn:
        session.query(Settings).filter(Settings.user_id == user_id).update({
            'detection_yn': False,
            'updated_at': datetime.now(),
        })
        session.commit()
    else:
        session.query(Settings).filter(Settings.user_id == user_id).update({
            'detection_yn': True,
            'updated_at': datetime.now(),
        })
        session.commit()

    return session.query(Settings).filter(Settings.user_id == user_id).first()


def get_detection_yn(user_id):
    return session.query(Settings).filter(Settings.user_id == user_id).first()