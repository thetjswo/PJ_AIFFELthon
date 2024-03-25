import logging
from datetime import datetime

from crud.inquiry import UserDAO, UserDeviceDAO
from db import db_connector

from sqlalchemy.orm import sessionmaker

from db.table_info import Users, UserDevices


def signup(data):
    Session = sessionmaker(bind=db_connector.engine)
    session = Session()

    values = Users(
        user_name=data.name,
        user_id=data.email,
        user_pw=data.password,
        phone_num=data.phone,
        is_agreed=data.agree,
        uid=data.uid,
        del_fl=False,
        rest_fl=False,
        role_type=1,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )

    session.add(values)
    session.commit()

    logging.info('success to insert about user info!')


def device_info(data):
    Session = sessionmaker(bind=db_connector.engine)
    session = Session()

    # users 테이블에서 uid가 data.uid와 같은 데이터 조회
    user = UserDAO.get_by_uid(data.user_uid)
    device = UserDeviceDAO.get_by_user_id(user.id)

    if device == None:
        values = UserDevices(
            manufacturer=data.manufacturer,
            device_name=data.device_name,
            device_model=data.device_model,
            os_version=data.os_version,
            uuid=data.uuid,
            push_id=data.push_id,
            app_version=data.app_version,
            del_fl=False,
            user_id=user.id,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )

        session.add(values)
        session.commit()

        logging.info('success to insert about user device info!')
    else:
        # TODO: 앱 업데이트 및 device 정보 갱신 시, update 쿼리 생성
        logging.info('This device is already exist!')