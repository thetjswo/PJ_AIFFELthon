import logging
from datetime import datetime
from db import db_connector, table_info

from sqlalchemy.orm import sessionmaker



def signup(data):
    Session = sessionmaker(bind=db_connector.engine)
    session = Session()

    values = table_info.Users(
        user_name=data.name,
        user_id=data.email,
        user_pw=data.password,
        phone_num=data.phone,
        is_agreed=data.agree,
        uid=data.uid,
        created_at=datetime.now()
    )

    session.add(values)
    session.commit()

    logging.info('success to insert about user info!')