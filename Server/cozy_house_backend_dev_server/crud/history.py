import json
import logging
from datetime import datetime

from db.dao.event_logs_dao import get_by_user_id
from db.dao.users_dao import get_only_user_id


# 선택한 날짜 영상 조회
def selected_date(param):
    # String 타입의 날짜 데이터를 datetime 형식으로 변환한 후, 시간 값 제거
    selected_date_str = param.date
    selected_datetime = datetime.strptime(selected_date_str, '%Y-%m-%d %H:%M:%S.%f')
    selected_date = selected_datetime.date()

    user_id = get_only_user_id(param.uid)
    event_logs = get_by_user_id(user_id, selected_date)

    data = {}
    for log_tuple in event_logs:
        log = log_tuple[0]  # 튜플의 첫 번째 요소는 EventLogs 객체
        cctv_name = log_tuple[1]  # 튜플의 두 번째 요소는 CCTV 장치 이름

        # 딕셔너리에 CCTV 이름이 이미 있는지 확인하고 없으면 빈 리스트로 초기화
        if cctv_name not in data:
            data[cctv_name] = []

        # 딕셔너리에 CCTV 이름에 해당하는 로그 추가
        data[cctv_name].append(serialize(log))

    # 결과 출력
    logging.info(f'list of event logs: ${data}')

    for camera in data:
        for log in data[camera]:
            # created_at 값에 .strftime() 처리
            log["created_at"] = log["created_at"].strftime("%Y-%m-%d %H:%M:%S")

    return data


def serialize(obj):
    if hasattr(obj, '__dict__'):
        return {k: v for k, v in obj.__dict__.items() if k != '_sa_instance_state'}
    return obj