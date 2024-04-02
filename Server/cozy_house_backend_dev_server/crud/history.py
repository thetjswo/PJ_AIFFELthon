import logging

from db.dao.cctv_videos_dao import get_by_user_id
from db.dao.users_dao import get_only_user_id


# 선택한 날짜 영상 조회
def selected_date(param):
    selected_datatime = param.date
    selected_date = selected_datatime.date()
    logging.info(f'!!!!!!!!!${selected_date}')

    user_id = get_only_user_id(param.uid)
    videos = get_by_user_id(user_id, selected_date)

    # videos에 담긴 데이터를 1개씩 분리, Json 형식으로 바꾸는 작업
    data = {}
    if videos is not None:
        # # user 객체의 데이터를 JSON으로 변환
        # data['result'] = True
        # data['uid'] = param.uid
        # data['cctv_name'] = device.cctv_name
        # data['is_checked'] = videos.is_checked
        # data['file_name'] = videos.file_name
        # data['file_path'] = videos.file_path
        # data['cctv_id'] = videos.cctv_id
        # data['type'] = 'Dangerous'    # TODO: type값 DB에서 가져오는 걸로 수정하기 => event_logs.type

        return data
    else:
        # 사용자를 찾지 못한 경우
        data['result'] = False
        return data