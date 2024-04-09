import cv2
from ultralytics import YOLO
import time
from collections import defaultdict
from ultralytics.utils.plotting import Annotator, colors

import asyncio
import logging

from datetime import datetime
import os
import sys

from cctv_server import camera_module
from crud.policy import get_policy_flag
from core.push_messaging import PushMessaging
from db.dao.user_devices_dao import get_push_id

# 다음 에러 방지용 : "interrupted by signal 11: SIGSEGV"
# os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE"

# 객체 감지 루프
async def object_detection_with_tracking(uid):

    # 상태 변수
    object_detection_running = False

    current_dir = os.path.dirname(__file__)

    model_path = os.path.abspath(os.path.join(current_dir, '..', 'resources', 'model', 'yolov8n.pt'))
    video_path = os.path.abspath(os.path.join(current_dir, '..', 'resources', 'videos'))
    thumbnail_path = os.path.abspath(os.path.join(current_dir, '..', 'resources', 'thumbnail'))

    # 객체 감지 루프
    async def object_detection_loop(uid):
        nonlocal object_detection_running  # global 변수 사용 설정

        # Load the YOLOv8 model - object detection
        model = YOLO(model_path)
        track_history = defaultdict(lambda: [])
        names = model.model.names

        # 사람 탐지 여부
        human_detected = False
        human_disappeared_time = None

        # 프레임 세는 변수
        human_frame_count = 0
        print("human_frame_count:", human_frame_count)

        # 감지 기점 타임스탬프
        recognition_start_time = {}

        cap = camera_module('object_detection')

        # webcam 예외처리
        if not cap.isOpened():
            print("Camera open failed!")
            sys.exit()

        w, h = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT))
        # fps = 30 # 초당 프레임 30 for most webcams
        fps = cap.get(cv2.CAP_PROP_FPS)  # 재생속도 테스트용

        # TODO: DB 저장 위치 연결

        while True:
            if object_detection_running == True:
                # 비디오의 각 프레임마다 객체 추적을 수행
                ret, frame = cap.read()

                # 예외처리 : 카메라 연결 안된 경우
                if not ret:
                    print("ret is not here!")
                    break

                # 실시간 객체 탐지
                print("====Start Object Detection====")
                results = model(frame, stream=True)

                # 사람 tracking
                human_tracking = model.track(frame, persist=True, verbose=False, classes=0)
                boxes = human_tracking[0].boxes.xyxy.cpu()

                # 사람이 감지되면
                if human_tracking[0].boxes.id is not None:
                    print("Human detected!")

                    human_frame_count += 1
                    print("human_frame_count:", human_frame_count)

                    # 사람이 처음 감지되었다면, 녹화 시작
                    if not human_detected:
                        human_detected = True
                        current_time = datetime.now().strftime("%d_%H%M%S")
                        file_name = f"real_time_detec_{current_time}.mp4"
                        video_saving = cv2.VideoWriter(os.path.join(video_path, file_name),
                                                       cv2.VideoWriter_fourcc(*'mp4v'),
                                                       fps,
                                                       (w, h))
                        human_disappeared_time = None

                        # thumbnail 저장 위치 생성
                        save_image_path = os.path.join(thumbnail_path, f"{file_name}.jpg")

                        # 사람 감지되자마자 첫프레임 저장
                        cv2.imwrite(save_image_path, frame)
                        print('saved first frame to thumbnail!')

                        # # 3초 뒤 프레임 섬네일로 저장 기능 구현중
                        # if human_frame_count == 3:
                        #     print('saved 3rd frame to thumbnail!')
                        #     cv2.imwrite(save_image_path, frame)

                        # excetpion handling : VideoWriter 파일이 안 열린경우
                        if not video_saving.isOpened():
                            print('File open failed!')
                            cap.release()
                            sys.exit()

                    # Extract prediction results
                    clss = human_tracking[0].boxes.cls.cpu().tolist()  # 추적된 객체의 class label
                    track_ids = human_tracking[0].boxes.id.int().cpu().tolist()  # 추적된 객체의 id
                    confs = human_tracking[0].boxes.conf.float().cpu().tolist()  # 추적된 객체의 신뢰도 점수 (정확성)

                    # Annotator Init
                    annotator = Annotator(frame, line_width=2)

                    for box, cls, track_id in zip(boxes, clss, track_ids):
                        # 현재 시각을 해당 객체 인식 시작 시각으로 업데이트
                        if track_id not in recognition_start_time:
                            recognition_start_time[track_id] = time.time()
                        annotator.box_label(box, color=colors(int(cls), True), label=names[int(cls)])  # 프레임에 BBox 그리기.

                        # 해당 객체의 추적 이력을 저장
                        track = track_history[track_id]  # track_history 딕셔너리에서 해당 객체의 추적 이력을 가져오기
                        track.append((int((box[0] + box[2]) / 2), int((box[1] + box[
                            3]) / 2)))  # 추적 이력에 현재 객체의 중심점 좌표를 추가. 중심점 좌표는 상자의 네 꼭짓점 좌표를 사용하여 계산.
                        if len(track) > 30:
                            track.pop(
                                0)  # 추적 이력의 길이가 30보다 크다면, 가장 오래된 추적 이력을 제거. (= 각 객체에 대해 최근 30프레임 동안의 이동 경로를 추적하고 기록한다)

                    # 객체 인식 기간(시간) 계산 및 출력
                    for track_id in recognition_start_time:
                        if track_id in track_ids:
                            recognition_duration = time.time() - recognition_start_time[track_id]

                        # 20초 이상 탐지되는 객체의 id 출력
                        if recognition_duration >= 20:
                            print(f"Object with track ID {track_id} recognized for {recognition_duration} seconds.")
                            # TODO: push 메세지 요청
                            # uid를 통해 해당 사용자의 fcm 토큰 조회
                            user_push_id = get_push_id(uid)
                            # fcm 토큰에 해당하는 단말기로 푸쉬 알림 전송 (일단 주의 푸쉬 전송)
                            PushMessaging.caution_push(user_push_id)


                    # 사람이 감지되면 프레임을 비디오에 쓰기
                    video_saving.write(frame)

                # 사람이 사라지면
                else:
                    if human_detected:
                        print("Human disappered!")
                        human_disappeared_time = time.time()  # 사라진 시간(human_disappeared_time) 기록
                        human_detected = False  # human_detected 변수 False로 수정
                        human_frame_count = 0  # 프레임 카운트 초기화

                # 사람이 사라지고 2가 지난뒤에
                if human_disappeared_time and (time.time() - human_disappeared_time >= 2):
                    video_saving.release()  # 영상 저장객체 해제
                    human_disappeared_time = None  # 사람 사라진 시간 변수(human_disappeared_time) 초기화

            else:
                break

            await asyncio.sleep(0.001)  # 다른 작업에 CPU 리소스를 할당하기 위해 잠시 대기

        cap.release()

    # app에서 데이터 받는 루프
    async def detection_flag_receive_loop(uid):
        nonlocal object_detection_running

        while True:
            try:
                detection_yn = get_policy_flag(uid)
                if detection_yn:
                    object_detection_running = detection_yn
                    logging.info("==Object detection started==")
                else:
                    object_detection_running = detection_yn
                    logging.info("==Object detection stopped==")

            except asyncio.TimeoutError:
                pass


    await asyncio.gather(
        detection_flag_receive_loop(uid),
        object_detection_loop(uid),
    )

# import os
# os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE"
#
# import cv2
# from ultralytics import YOLO
# import time
# from collections import defaultdict
# from ultralytics.utils.plotting import Annotator, colors
#
# import asyncio
# import logging
#
# from datetime import datetime
# import os
# import sys
#
# from cctv_server import camera_module
# from crud.policy import get_policy_flag
#
#
# # 객체 감지 루프
# async def object_detection_with_tracking(detection_yn, uid):
#
#     current_dir = os.path.dirname(__file__)
#     print('1')
#
#     model_path = os.path.abspath(os.path.join(current_dir, '..', 'resources', 'model', 'yolov8n.pt'))
#     video_path = os.path.abspath(os.path.join(current_dir, '..', 'resources', 'videos'))
#     thumbnail_path = os.path.abspath(os.path.join(current_dir, '..', 'resources', 'thumbnail'))
#
#     # Load the YOLOv8 model - object detection
#     model = YOLO(model_path)
#     print('2')
#     track_history = defaultdict(lambda: [])
#     names = model.model.names
#
#     # 사람 탐지 여부
#     human_detected = False
#     human_disappeared_time = None
#
#     # 프레임 세는 변수
#     human_frame_count = 0
#     print("human_frame_count:", human_frame_count)
#
#     # 감지 기점 타임스탬프
#     recognition_start_time = {}
#
#     # cap = camera_module('object_detection')
#     cap = cv2.VideoCapture(1)
#
#     # webcam 예외처리
#     if not cap.isOpened():
#         print("Camera open failed!")
#         sys.exit()
#
#     w, h = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT))
#     # fps = 30 # 초당 프레임 30 for most webcams
#     fps = cap.get(cv2.CAP_PROP_FPS)  # 재생속도 테스트용
#
#     # TODO: DB 저장 위치 연결
#
#     while True:
#         if detection_yn:
#             # 비디오의 각 프레임마다 객체 추적을 수행
#             ret, frame = cap.read()
#
#             # 예외처리 : 카메라 연결 안된 경우
#             if not ret:
#                 print("ret is not here!")
#                 break
#
#             # 실시간 객체 탐지
#             print("====Start Object Detection====")
#             results = model(frame, stream=True)
#
#             # 사람 tracking
#             human_tracking = model.track(frame, persist=True, verbose=False, classes=0)
#             boxes = human_tracking[0].boxes.xyxy.cpu()
#
#             # 사람이 감지되면
#             if human_tracking[0].boxes.id is not None:
#                 print("Human detected!")
#
#                 human_frame_count += 1
#                 print("human_frame_count:", human_frame_count)
#
#                 # 사람이 처음 감지되었다면, 녹화 시작
#                 if not human_detected:
#                     human_detected = True
#                     current_time = datetime.now().strftime("%d_%H%M%S")
#                     file_name = f"real_time_detec_{current_time}.mp4"
#                     video_saving = cv2.VideoWriter(os.path.join(video_path, file_name),
#                                                    cv2.VideoWriter_fourcc(*'mp4v'),
#                                                    fps,
#                                                    (w, h))
#                     human_disappeared_time = None
#
#                     # thumbnail 저장 위치 생성
#                     save_image_path = os.path.join(thumbnail_path, f"{file_name}.jpg")
#
#                     # 사람 감지되자마자 첫프레임 저장
#                     cv2.imwrite(save_image_path, frame)
#                     print('saved first frame to thumbnail!')
#
#                     # # 3초 뒤 프레임 섬네일로 저장 기능 구현중
#                     # if human_frame_count == 3:
#                     #     print('saved 3rd frame to thumbnail!')
#                     #     cv2.imwrite(save_image_path, frame)
#
#                     # excetpion handling : VideoWriter 파일이 안 열린경우
#                     if not video_saving.isOpened():
#                         print('File open failed!')
#                         cap.release()
#                         sys.exit()
#
#                 # Extract prediction results
#                 clss = human_tracking[0].boxes.cls.cpu().tolist()  # 추적된 객체의 class label
#                 track_ids = human_tracking[0].boxes.id.int().cpu().tolist()  # 추적된 객체의 id
#                 confs = human_tracking[0].boxes.conf.float().cpu().tolist()  # 추적된 객체의 신뢰도 점수 (정확성)
#
#                 # Annotator Init
#                 annotator = Annotator(frame, line_width=2)
#
#                 for box, cls, track_id in zip(boxes, clss, track_ids):
#                     # 현재 시각을 해당 객체 인식 시작 시각으로 업데이트
#                     if track_id not in recognition_start_time:
#                         recognition_start_time[track_id] = time.time()
#                     annotator.box_label(box, color=colors(int(cls), True), label=names[int(cls)])  # 프레임에 BBox 그리기.
#
#                     # 해당 객체의 추적 이력을 저장
#                     track = track_history[track_id]  # track_history 딕셔너리에서 해당 객체의 추적 이력을 가져오기
#                     track.append((int((box[0] + box[2]) / 2), int((box[1] + box[
#                         3]) / 2)))  # 추적 이력에 현재 객체의 중심점 좌표를 추가. 중심점 좌표는 상자의 네 꼭짓점 좌표를 사용하여 계산.
#                     if len(track) > 30:
#                         track.pop(
#                             0)  # 추적 이력의 길이가 30보다 크다면, 가장 오래된 추적 이력을 제거. (= 각 객체에 대해 최근 30프레임 동안의 이동 경로를 추적하고 기록한다)
#
#                 # 객체 인식 기간(시간) 계산 및 출력
#                 for track_id in recognition_start_time:
#                     if track_id in track_ids:
#                         recognition_duration = time.time() - recognition_start_time[track_id]
#
#                     # 20초 이상 탐지되는 객체의 id 출력
#                     if recognition_duration >= 20:
#                         print(f"Object with track ID {track_id} recognized for {recognition_duration} seconds.")
#                         # TODO: push 메세지 요청
#
#                 # 사람이 감지되면 프레임을 비디오에 쓰기
#                 video_saving.write(frame)
#
#             # 사람이 사라지면
#             else:
#                 if human_detected:
#                     print("Human disappered!")
#                     human_disappeared_time = time.time()  # 사라진 시간(human_disappeared_time) 기록
#                     human_detected = False  # human_detected 변수 False로 수정
#                     human_frame_count = 0  # 프레임 카운트 초기화
#
#             # 사람이 사라지고 2가 지난뒤에
#             if human_disappeared_time and (time.time() - human_disappeared_time >= 2):
#                 video_saving.release()  # 영상 저장객체 해제
#                 human_disappeared_time = None  # 사람 사라진 시간 변수(human_disappeared_time) 초기화
#         else:
#             break
#
#         await asyncio.sleep(0.001)  # 다른 작업에 CPU 리소스를 할당하기 위해 잠시 대기
#
#     cap.release()