import logging
from datetime import datetime
from db import db_connector, table_info

from sqlalchemy.orm import sessionmaker


def signup(data):
    Session = sessionmaker(bind=db_connector.engine)
    session = Session()
    # table = db.Table('users', db_connector.metadata, autoload=False)

    values = table_info.Users(
        user_name=data.name,
        user_id=data.email,
        user_pw=data.password,
        phone_num=data.phone,
        is_agreed=data.agree,
        # TODO: 배포 시, role 제거
        role_type=data.role,
        created_at=datetime.now()
    )

    session.add(values)
    session.commit()
    # query = db.insert(table).values(
    #
    # )
    # result_proxy = db_connector.connection.execute(query)
    # result_proxy.close()

    logging.info('success to insert about user info!')