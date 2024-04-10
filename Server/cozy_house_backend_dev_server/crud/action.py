from db.dao.cctv_videos_dao import get_video_info_by_id
from utils import convert_file_to_binary


def selected_video(video_id):
    result = get_video_info_by_id(video_id)

    # TODO: 영상 DB 처리 구현 시, 실제 파일명으로 불러오기
    # video_path = result[0].file_path + result[0].file_name + '.mp4'
    # video_path = './resources/videos/sample_video.mp4'
    # video_data = convert_file_to_binary(video_path)

    thumbnail_path = result[0].cap_path + result[0].file_name + '.jpg'
    thumbnail_data = convert_file_to_binary(thumbnail_path)

    camera_name = result[1]
    created_at = str(result[0].created_at)

    data = {
        # 'video': video_data,
        'thumbnail': thumbnail_data,
        'camera_name': camera_name,
        'created_at': created_at
    }

    return data