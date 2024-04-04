# yolo_v8_detection_for_server : yolo_v8_detection 을 함수화

import cv2
from ultralytics import YOLO
import numpy as np
from time import time
from collections import defaultdict
from ultralytics.utils.plotting import Annotator, colors

from datetime import datetime  # 파일명에 시간을 추가하기 위한 datetime 라이브러리
import os  # 폴더 생성을 위해 추가
import re

import logging # log 출력을 위한 라이브러리


async def object_detection_with_tracking(video_path="../../../Model/yolov8_test_seul/sample_data/sample_video.mp4"):
    # Load the YOLOv8 model - object detection
    model = YOLO('yolov8n.pt')
    track_history = defaultdict(lambda: [])
    names = model.model.names

    # # webcam 사용 시 - 실시간 개체 추적
    # cap = cv2.VideoCapture(0)     # 사용할 camera index 사용 - 0 : 랩탑 카메라, 1 : 핸드폰 연결 카메라(슬 경우)
    
    # using sample video file
    cap = cv2.VideoCapture(video_path)
    # assert cap.isOpened(), "Error reading video file"
    
    w, h, fps = (int(cap.get(x)) for x in (cv2.CAP_PROP_FRAME_WIDTH, cv2.CAP_PROP_FRAME_HEIGHT, cv2.CAP_PROP_FPS))

    # 현재 시간을 포맷에 맞게 문자열로 변환하여 파일명에 추가
    current_time = datetime.now().strftime("%d_%H%M%S")
    # 파일명에 현재 시간 추가
    file_name = f"test_video_20sec_detec_{current_time}.mp4"

    folder_path = "./result"

    # 만약 폴더가 존재하지 않으면 폴더 생성
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    
    # VideoWriter 객체 생성
    result = cv2.VideoWriter(os.path.join(folder_path, file_name),  
                             cv2.VideoWriter_fourcc(*'mp4v'),      # macOS MP4 코덱인 MP4V로 FourCC 코드 설정
                             fps,
                             (w, h))

    recognition_start_time = {}

     # 카메라 / 비디오로부터 프레임 읽어오기
    while cap.isOpened():
        # 비디오의 각 프레임마다 객체 추적을 수행
        success, frame = cap.read()
        
        # video_test라는 이름의 창에 프레임 출력
        cv2.imshow('result_video', frame)
        
        # success 변수가 True일 때 (비디오 프레임을 제대로 읽어왔을 때) 실행됨.
        if success:
            results = model.track(frame, persist=True, verbose=False, classes=0)
            boxes = results[0].boxes.xyxy.cpu()

            # 추적 결과에 대한 상자 정보가 있는 경우 아래 작업을 수행
            if results[0].boxes.id is not None:

                # Extract prediction results
                clss = results[0].boxes.cls.cpu().tolist()   # 추적된 객체의 class label
                track_ids = results[0].boxes.id.int().cpu().tolist()   # 추적된 객체의 id
                confs = results[0].boxes.conf.float().cpu().tolist()   # 추적된 객체의 신뢰도 점수 (정확성)

                # Annotator Init
                annotator = Annotator(frame, line_width=2)

                for box, cls, track_id in zip(boxes, clss, track_ids):
                    # 현재 시각을 해당 객체 인식 시작 시각으로 업데이트
                    if track_id not in recognition_start_time:
                        recognition_start_time[track_id] = time()
                    annotator.box_label(box, color=colors(int(cls), True), label=names[int(cls)])    # 프레임에 BBox 그리기. 

                    # 해당 객체의 추적 이력을 저장
                    track = track_history[track_id]    # track_history 딕셔너리에서 해당 객체의 추적 이력을 가져오기
                    track.append((int((box[0] + box[2]) / 2), int((box[1] + box[3]) / 2)))     # 추적 이력에 현재 객체의 중심점 좌표를 추가. 중심점 좌표는 상자의 네 꼭짓점 좌표를 사용하여 계산.
                    if len(track) > 30:
                        track.pop(0)     # 추적 이력의 길이가 30보다 크다면, 가장 오래된 추적 이력을 제거. (= 각 객체에 대해 최근 30프레임 동안의 이동 경로를 추적하고 기록한다)

                    # 추적 이력을 사용하여 추적 경로 그리기 
                    points = np.array(track, dtype=np.int32).reshape((-1, 1, 2))     # 추적 이력을 넘파이 배열로 변환
                    cv2.circle(frame, (track[-1]), 7, colors(int(cls), True), -1)    # cv2.circle() 함수를 사용하여 추적 경로의 마지막 점에 원을 그리기
                    cv2.polylines(frame, [points], isClosed=False, color=colors(int(cls), True), thickness=2)   # cv2.polylines() 함수를 사용하여 추적 경로를 선으로 그리기

                # 객체 인식 기간(시간) 계산 및 출력    
                for track_id in recognition_start_time:
                    if track_id in track_ids:
                        recognition_duration = time() - recognition_start_time[track_id]
                        
                    # 20초 이상 탐지되는 객체의 id 출력
                    if recognition_duration >= 20 :
                        print(f"Object with track ID {track_id} recognized for {recognition_duration} seconds.")

            result.write(frame)

            if cv2.waitKey(1) & 0xFF == ord("q"):
                break
        else:
            break

    result.release()
    cap.release()
    cv2.destroyAllWindows()
    
    return result


# # 이 파일을 직접 실행할때
# video_path = "./sample_data/sample_video.mp4"

# # # server에서 모델 호출할때 : server 파일 실행 위치에서 상대경로
# # video_path = "../../../Model/sample_data/sample_video.mp4"

# result_video_path = object_detection_with_tracking(video_path)
# logging.info(f"Result video saved at: {result_video_path}")
