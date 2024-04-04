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