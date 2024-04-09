import logging

from db.dao.settings_dao import update_detection_yn, get_detection_yn
from db.dao.users_dao import get_only_user_id


def change_policy_flag(param):
    user_id = get_only_user_id(param.uid)
    settings = update_detection_yn(user_id)

    return settings.detection_yn


def get_policy_flag(uid):
    user_id = get_only_user_id(uid)
    settings = get_detection_yn(user_id)

    return settings.detection_yn
